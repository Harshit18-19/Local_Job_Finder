import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/job.dart';
import '../models/job_data.dart';
import '../services/applied_jobs_service.dart';
import 'job_detail_screen.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  List<Job> _jobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await AppliedJobsService.getAppliedIds();
    if (!mounted) return;
    setState(() {
      _jobs = sampleJobs.where((job) => ids.contains(job.id)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Applied Jobs',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _jobs.isEmpty
              ? _buildEmpty()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _approvalHeader(isDark),
                    const SizedBox(height: 16),
                    ..._jobs.map(_jobTile),
                  ],
                ),
    );
  }

  Widget _approvalHeader(bool isDark) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFED7AA)),
        ),
        child: const Row(
          children: [
            Icon(Icons.hourglass_top_rounded, color: Color(0xFFEA580C)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Awaiting approval',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  SizedBox(height: 3),
                  Text('Employers will review your applications here.',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _jobTile(Job job) {
    final accent = Color(job.cardColor);
    return FadeInUp(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => JobDetailScreen(job: job))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                    backgroundColor: accent,
                    child: Text(job.company[0],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(job.title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(job.company,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 10),
                      const Row(children: [
                        Icon(Icons.hourglass_top_rounded,
                            size: 15, color: Color(0xFFEA580C)),
                        SizedBox(width: 5),
                        Text('Pending employer approval',
                            style: TextStyle(
                                color: Color(0xFFEA580C),
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: FadeIn(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
                color: Color(0xFFFFEDD5), shape: BoxShape.circle),
            child: const Icon(Icons.assignment_outlined,
                size: 48, color: Color(0xFFEA580C)),
          ),
          const SizedBox(height: 20),
          const Text('No applications yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Applied jobs awaiting approval will appear here.',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ])),
      );
}
