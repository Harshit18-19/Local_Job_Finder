import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/job.dart';
import '../models/job_data.dart';
import '../services/saved_jobs_service.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  List<Job> _savedJobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await SavedJobsService.getSavedIds();
    setState(() {
      _savedJobs = sampleJobs.where((j) => ids.contains(j.id)).toList();
      _loading = false;
    });
  }

  void _openDetail(Job job) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => JobDetailScreen(job: job),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Saved Jobs', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _savedJobs.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  itemCount: _savedJobs.length,
                  itemBuilder: (_, i) => JobCard(
                    job: _savedJobs[i],
                    index: i,
                    onTap: () => _openDetail(_savedJobs[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_border_rounded,
                  size: 48, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('No saved jobs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Bookmark jobs to find them here',
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
