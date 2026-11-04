import 'package:flutter/material.dart';

import '../models/application.dart';
import '../services/application_service.dart';

class ReviewerApplicationsScreen extends StatelessWidget {
  const ReviewerApplicationsScreen({super.key});

  Future<void> _review(BuildContext context, JobApplication application) async {
    final noteController = TextEditingController();
    final decision = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Review ${application.applicantName}'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Optional note for applicant',
            hintText: 'Add a short message',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'rejected'),
            child: const Text('Reject'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, 'approved'),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (decision == null) {
      noteController.dispose();
      return;
    }
    try {
      await ApplicationService.review(
        applicationId: application.id,
        status: decision,
        note: noteController.text,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Application ${decision == 'approved' ? 'approved' : 'rejected'}',
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save this decision.')),
        );
      }
    } finally {
      noteController.dispose();
    }
  }

  Future<void> _advanceStage(
    BuildContext context,
    JobApplication application,
  ) async {
    final nextIndex = application.stageIndex + 1;
    try {
      await ApplicationService.advanceStage(
        applicationId: application.id,
        stageIndex: nextIndex,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved to ${application.interviewStages[nextIndex]}'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update interview stage.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Application approvals')),
    body: StreamBuilder<List<JobApplication>>(
      stream: ApplicationService.pendingForReview(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Unable to load applications.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final applications = snapshot.data!;
        if (applications.isEmpty) {
          return const Center(child: Text('No pending applications.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: applications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final application = applications[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.jobTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(application.company),
                    const Divider(height: 24),
                    Text(
                      application.applicantName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(application.applicantEmail),
                    Text(application.applicantPhone),
                    const SizedBox(height: 8),
                    Text(
                      'Interview stage: ${application.interviewStages[application.stageIndex.clamp(0, application.interviewStages.length - 1)]}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (application.skills.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text('Skills: ${application.skills}'),
                    ],
                    if (application.profileUrl.isNotEmpty)
                      Text('Profile: ${application.profileUrl}'),
                    if (application.coverLetter.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(application.coverLetter),
                    ],
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          if (application.stageIndex <
                              application.interviewStages.length - 1)
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _advanceStage(context, application),
                              icon: const Icon(Icons.trending_up_rounded),
                              label: const Text('Advance stage'),
                            ),
                          FilledButton.icon(
                            onPressed: () => _review(context, application),
                            icon: const Icon(Icons.fact_check_outlined),
                            label: const Text('Decide'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
