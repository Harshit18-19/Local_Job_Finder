import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/application.dart';
import '../services/application_service.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
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
      body: StreamBuilder<List<JobApplication>>(
        stream: ApplicationService.mine(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _buildError();
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final applications = snapshot.data!;
          if (applications.isEmpty) return _buildEmpty();
          return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _approvalHeader(isDark),
                    const SizedBox(height: 16),
                    ...applications.map(_applicationTile),
                  ],
                );
        },
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

  Widget _applicationTile(JobApplication application) {
    final approved = application.status == 'approved';
    final rejected = application.status == 'rejected';
    final color = approved
        ? const Color(0xFF059669)
        : rejected ? const Color(0xFFDC2626) : const Color(0xFFEA580C);
    final icon = approved
        ? Icons.check_circle_rounded
        : rejected ? Icons.cancel_rounded : Icons.hourglass_top_rounded;
    final status = approved
        ? 'Approved by employer'
        : rejected ? 'Not selected' : 'Pending employer approval';
    return FadeInUp(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                    backgroundColor: color,
                    child: Text(application.company.isEmpty ? '?' : application.company[0],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(application.jobTitle,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(application.company,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 10),
                      Row(children: [
                        Icon(icon, size: 15, color: color),
                        const SizedBox(width: 5),
                        Text(status,
                            style: TextStyle(color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ]),
                      if (application.reviewerNote?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 6),
                        Text(application.reviewerNote!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ])),
              ],
            ),
          ),
      ),
      );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Unable to load applications. Check your Firebase connection and security rules.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
        ),
      );

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
