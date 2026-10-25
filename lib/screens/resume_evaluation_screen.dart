import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../models/job.dart';
import '../models/job_data.dart';
import '../services/resume_ats_service.dart';

class ResumeEvaluationScreen extends StatefulWidget {
  final Job? initialJob;

  const ResumeEvaluationScreen({super.key, this.initialJob});

  @override
  State<ResumeEvaluationScreen> createState() => _ResumeEvaluationScreenState();
}

class _ResumeEvaluationScreenState extends State<ResumeEvaluationScreen> {
  static const _maxFileBytes = 12 * 1024 * 1024;
  static const _maxPages = 20;

  late Job _targetJob;
  PlatformFile? _resumeFile;
  ResumeAtsEvaluation? _evaluation;
  String? _error;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _targetJob = widget.initialJob ?? sampleJobs.first;
  }

  Future<void> _choosePdf() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (file == null || !mounted) return;

      final byteCount = file.lengthSync() ?? await file.length();
      if (byteCount != null && byteCount > _maxFileBytes) {
        setState(() {
          _error = 'Choose a PDF smaller than 12 MB.';
          _resumeFile = null;
          _evaluation = null;
        });
        return;
      }

      setState(() {
        _resumeFile = file;
        _evaluation = null;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = 'Could not open the file picker. Please try again.',
      );
    }
  }

  Future<void> _evaluateResume() async {
    final file = _resumeFile;
    if (file == null) {
      setState(() => _error = 'Choose a PDF resume first.');
      return;
    }

    setState(() {
      _working = true;
      _error = null;
      _evaluation = null;
    });

    PdfDocument? document;
    try {
      final bytes = await file.readAsBytes();
      if (bytes.length > _maxFileBytes) {
        throw const _ResumeCheckException('Choose a PDF smaller than 12 MB.');
      }

      document = await PdfDocument.openData(bytes, sourceName: file.name);
      final pageCount = document.pages.length;
      if (pageCount == 0) {
        throw const _ResumeCheckException(
          'This PDF does not contain any pages.',
        );
      }
      if (pageCount > _maxPages) {
        throw const _ResumeCheckException(
          'For a quick check, choose a resume with 20 pages or fewer.',
        );
      }

      final text = StringBuffer();
      for (final page in document.pages) {
        final pageText = await page.loadText();
        if (pageText != null) {
          text.writeln(pageText.fullText);
        }
      }
      final resumeText = text.toString();
      final wordCount = RegExp(r"[a-zA-Z0-9+#.']+")
          .allMatches(resumeText)
          .length;
      if (wordCount < 80) {
        throw const _ResumeCheckException(
          'We could not read enough text in this PDF. It may be a scanned image. Export a text-selectable PDF and try again.',
        );
      }

      final result = ResumeAtsService.evaluate(
        resumeText: resumeText,
        pageCount: pageCount,
        targetJob: _targetJob,
      );
      if (!mounted) return;
      setState(() => _evaluation = result);
    } on _ResumeCheckException catch (exception) {
      if (mounted) setState(() => _error = exception.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'This PDF could not be read. Check that it opens normally and is not password-protected.',
        );
      }
    } finally {
      await document?.dispose();
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF4F7FC),
      appBar: AppBar(title: const Text('Free Resume ATS Check')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        children: [
          _introCard(),
          const SizedBox(height: 20),
          _sectionTitle('1. Choose a target job'),
          const SizedBox(height: 8),
          DropdownButtonFormField<Job>(
            initialValue: _targetJob,
            isExpanded: true,
            decoration: _inputDecoration(isDark),
            items: sampleJobs
                .map(
                  (job) => DropdownMenuItem(
                    value: job,
                    child: Text(
                      '${job.title} · ${job.company}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: _working
                ? null
                : (job) => setState(() {
                    _targetJob = job ?? sampleJobs.first;
                    _evaluation = null;
                  }),
          ),
          const SizedBox(height: 18),
          _sectionTitle('2. Upload your resume PDF'),
          const SizedBox(height: 8),
          _fileCard(isDark),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _working ? null : _evaluateResume,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: _working
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.analytics_outlined),
            label: Text(_working ? 'Reading your PDF…' : 'Check my ATS score'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _errorCard(_error!),
          ],
          if (_evaluation case final evaluation?) ...[
            const SizedBox(height: 22),
            _buildResults(evaluation, isDark),
          ],
          const SizedBox(height: 20),
          _safeResumeTips(isDark),
        ],
      ),
    );
  }

  Widget _introCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1D4ED8), Color(0xFF0891B2)],
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.verified_user_outlined, color: Colors.white, size: 28),
        SizedBox(height: 10),
        Text(
          'A free, private resume check',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Your PDF is analyzed on this device. It is not sent to a server or attached to an application.',
          style: TextStyle(color: Colors.white, height: 1.4, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _fileCard(bool isDark) => Material(
    color: isDark ? const Color(0xFF1E293B) : Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _working ? null : _choosePdf,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resumeFile?.name ?? 'Select a PDF from your device',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _resumeFile == null
                        ? 'PDF only · up to 12 MB'
                        : 'Ready to analyze · PDF stays on this device',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _resumeFile == null ? 'Choose' : 'Change',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildResults(ResumeAtsEvaluation evaluation, bool isDark) {
    final scoreColor = evaluation.score >= 90
        ? const Color(0xFF059669)
        : evaluation.score >= 75
        ? const Color(0xFF2563EB)
        : evaluation.score >= 60
        ? const Color(0xFFD97706)
        : const Color(0xFFDC2626);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Your evaluation'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 142,
                height: 142,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: evaluation.score / 100,
                        strokeWidth: 12,
                        backgroundColor: scoreColor.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(scoreColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${evaluation.score}',
                          style: TextStyle(
                            color: scoreColor,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '/ 100',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                evaluation.level,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Compared with ${_targetJob.title} at ${_targetJob.company} · ${evaluation.wordCount} words · ${evaluation.pageCount} pages',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...evaluation.categories.map(
          (category) => _categoryCard(category, isDark),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF2563EB).withValues(alpha: 0.15),
            ),
          ),
          child: const Text(
            'Score guide: 90–100 excellent structure; 75–89 strong; 60–74 needs a few changes; below 60 needs focused work. This is a checklist estimate—not an employer ATS result or a hiring probability.',
            style: TextStyle(fontSize: 12, height: 1.45),
          ),
        ),
      ],
    );
  }

  Widget _categoryCard(ResumeAtsCategory category, bool isDark) {
    final progress = category.maximum == 0
        ? 0.0
        : category.points / category.maximum;
    final color = progress >= 0.8
        ? const Color(0xFF059669)
        : progress >= 0.5
        ? const Color(0xFFD97706)
        : const Color(0xFFDC2626);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${category.points}/${category.maximum}',
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.detail,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
          if (progress < 1) ...[
            const SizedBox(height: 7),
            Text(
              'Next step: ${category.improvement}',
              style: const TextStyle(fontSize: 12, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }

  Widget _safeResumeTips(bool isDark) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.tips_and_updates_outlined, color: Color(0xFFD97706)),
            SizedBox(width: 8),
            Text(
              'Make your resume stronger',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _tip('Use a simple, single-column layout with standard headings.'),
        _tip(
          'Tailor skills and wording to the job, but only if they are true.',
        ),
        _tip('Show results with real numbers; never invent achievements.'),
        _tip('Keep contact details as selectable text, not an image or icon.'),
        const SizedBox(height: 8),
        Text(
          'ATS products and employer settings differ. No score can guarantee that a resume will pass a screen or lead to an interview.',
          style: TextStyle(color: Colors.grey[500], fontSize: 11, height: 1.4),
        ),
      ],
    ),
  );

  Widget _tip(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  ', style: TextStyle(color: Color(0xFF2563EB))),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
  );

  InputDecoration _inputDecoration(bool isDark) => InputDecoration(
    filled: true,
    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );

  Widget _errorCard(String message) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFDC2626).withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: Color(0xFFDC2626),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );
}

class _ResumeCheckException implements Exception {
  final String message;
  const _ResumeCheckException(this.message);
}
