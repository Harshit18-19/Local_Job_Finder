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
      backgroundColor: isDark
          ? const Color(0xFF0A0F1E)
          : const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text(
          'Applied Jobs',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      body: StreamBuilder<List<JobApplication>>(
        stream: ApplicationService.mine(),
        builder: (context, snapshot) {
          if (snapshot.hasError &&
              (!snapshot.hasData || snapshot.data!.isEmpty)) {
            return _buildError();
          }
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final applications = snapshot.data!;
          if (applications.isEmpty) return _buildEmpty();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _notificationBar(applications, isDark),
              const SizedBox(height: 16),
              _progressSection(applications, isDark),
              const SizedBox(height: 16),
              _sectionHeading('Application details'),
              const SizedBox(height: 10),
              ...applications.map(_applicationTile),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeading(String title) => Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
  );

  Widget _progressSection(List<JobApplication> applications, bool isDark) {
    final trackable = applications;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('Interview progress'),
        const SizedBox(height: 4),
        Text(
          'Track each application through the employer’s hiring stages.',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 10),
        if (trackable.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Your active applications and their interview stages will appear here.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          )
        else
          ...trackable.map((application) => _progressCard(application, isDark)),
      ],
    );
  }

  Widget _progressCard(JobApplication application, bool isDark) {
    final stages = application.interviewStages;
    final currentIndex = application.status == 'approved'
        ? stages.length - 1
        : application.stageIndex.clamp(0, stages.length - 1);
    final progress = currentIndex / (stages.length - 1);
    final localOnly = application.status == 'local';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${application.jobTitle} · ${application.company}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.blue.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(stages.length, (index) {
                final reached = index <= currentIndex;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: reached
                        ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    stages[index],
                    style: TextStyle(
                      color: reached
                          ? const Color(0xFF2563EB)
                          : Colors.grey[600],
                      fontSize: 10,
                      fontWeight: reached ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              localOnly
                  ? 'Saved on this device; interview updates are unavailable.'
                  : application.status == 'rejected'
                  ? 'Application closed: not selected.'
                  : application.status == 'approved'
                  ? 'Employer approved this application. This is not a job offer.'
                  : 'Current stage: ${stages[currentIndex]}',
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationBar(List<JobApplication> applications, bool isDark) {
    final pending = applications
        .where((item) => item.status == 'pending')
        .length;
    final approved = applications
        .where((item) => item.status == 'approved')
        .length;
    final rejected = applications
        .where((item) => item.status == 'rejected')
        .length;
    final localOnly = applications
        .where((item) => item.status == 'local')
        .length;
    final updateCount = pending + approved + rejected + localOnly;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Application notifications',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$updateCount',
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pending > 0)
            _noticeLine(
              icon: Icons.hourglass_top_rounded,
              color: const Color(0xFFEA580C),
              text:
                  '$pending application${pending == 1 ? '' : 's'} pending review. This page updates when a reviewer records a decision.',
            ),
          if (approved > 0)
            _noticeLine(
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF059669),
              text:
                  '$approved application${approved == 1 ? '' : 's'} approved. Check the application card for any reviewer note. Approval is not a job offer.',
            ),
          if (rejected > 0)
            _noticeLine(
              icon: Icons.cancel_outlined,
              color: const Color(0xFFDC2626),
              text:
                  '$rejected application${rejected == 1 ? '' : 's'} rejected. Check the application card for any reviewer note.',
            ),
          if (localOnly > 0)
            _noticeLine(
              icon: Icons.phone_iphone_rounded,
              color: const Color(0xFF64748B),
              text:
                  '$localOnly application${localOnly == 1 ? '' : 's'} saved on this device only. These were not sent to the backend.',
            ),
          if (updateCount == 0)
            Text(
              'Application updates will appear here.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _noticeLine({
    required IconData icon,
    required Color color,
    required String text,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _applicationTile(JobApplication application) {
    final approved = application.status == 'approved';
    final rejected = application.status == 'rejected';
    final localOnly = application.status == 'local';
    final color = approved
        ? const Color(0xFF059669)
        : rejected
        ? const Color(0xFFDC2626)
        : localOnly
        ? const Color(0xFF64748B)
        : const Color(0xFFEA580C);
    final icon = approved
        ? Icons.check_circle_rounded
        : rejected
        ? Icons.cancel_rounded
        : localOnly
        ? Icons.phone_iphone_rounded
        : Icons.hourglass_top_rounded;
    final status = approved
        ? 'Approved by employer'
        : rejected
        ? 'Not selected'
        : localOnly
        ? 'Saved on device only — not sent'
        : 'Pending employer approval';
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
                child: Text(
                  application.company.isEmpty ? '?' : application.company[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.jobTitle,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      application.company,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(icon, size: 15, color: color),
                        const SizedBox(width: 5),
                        Text(
                          status,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (application.reviewerNote?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 6),
                      Text(
                        application.reviewerNote!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Unable to load applications. Check your Firebase connection and security rules.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600]),
      ),
    ),
  );

  Widget _buildEmpty() => Center(
    child: FadeIn(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEDD5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 48,
              color: Color(0xFFEA580C),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No applications yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Applied jobs awaiting approval will appear here.',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    ),
  );
}
