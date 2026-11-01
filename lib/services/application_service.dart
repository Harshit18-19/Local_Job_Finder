import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/application.dart';
import '../models/job.dart';
import 'applied_jobs_service.dart';
import 'firebase_backend_service.dart';

class ApplicationService {
  static CollectionReference<Map<String, dynamic>> get _applications =>
      FirebaseFirestore.instance.collection('applications');

  static Future<bool> submit({
    required Job job,
    required String name,
    required String email,
    required String phone,
    required String skills,
    required String profileUrl,
    required String coverLetter,
  }) async {
    if (await AppliedJobsService.hasApplied(job.id)) {
      throw StateError('You have already applied for this job.');
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    User? firebaseUser;
    if (FirebaseBackendService.isReady) {
      try {
        firebaseUser = await FirebaseBackendService.ensureSignedIn().timeout(
          const Duration(seconds: 8),
        );
        final existing = await _applications
            .where('applicantId', isEqualTo: firebaseUser.uid)
            .where('jobId', isEqualTo: job.id)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 8));
        if (existing.docs.isNotEmpty) {
          throw StateError('You have already applied for this job.');
        }
      } on StateError {
        rethrow;
      } catch (_) {
        firebaseUser = null;
      }
    }

    final localApplication = {
      'id': id,
      'applicantId': firebaseUser?.uid ?? 'local',
      'applicantName': name,
      'applicantEmail': email,
      'applicantPhone': phone,
      'skills': skills,
      'profileUrl': profileUrl,
      'coverLetter': coverLetter,
      'jobId': job.id,
      'jobTitle': job.title,
      'company': job.company,
      'status': 'local',
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
    };
    await AppliedJobsService.addApplication(localApplication);

    if (firebaseUser == null) return false;
    try {
      await _applications
          .add({
            'applicantId': firebaseUser.uid,
            'applicantName': name,
            'applicantEmail': email,
            'applicantPhone': phone,
            'skills': skills,
            'profileUrl': profileUrl,
            'coverLetter': coverLetter,
            'jobId': job.id,
            'jobTitle': job.title,
            'company': job.company,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 8));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Stream<List<JobApplication>> mine() async* {
    final localApplications = (await AppliedJobsService.getApplications())
        .map(JobApplication.fromLocal)
        .toList();
    yield localApplications;
    if (!FirebaseBackendService.isReady) return;

    try {
      final user = await FirebaseBackendService.ensureSignedIn().timeout(
        const Duration(seconds: 8),
      );
      yield* _applications
          .where('applicantId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
            final remote =
                snapshot.docs.map(JobApplication.fromFirestore).toList()..sort(
                  (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0)
                      .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0),
                );
            final remoteJobIds = remote
                .map((application) => application.jobId)
                .toSet();
            final localOnly = localApplications.where(
              (application) => !remoteJobIds.contains(application.jobId),
            );
            return [...remote, ...localOnly];
          });
    } catch (_) {
      return;
    }
  }

  static Stream<List<JobApplication>> pendingForReview() async* {
    if (!FirebaseBackendService.isReady ||
        !await FirebaseBackendService.isReviewer()) {
      yield const [];
      return;
    }
    yield* _applications
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(JobApplication.fromFirestore).toList()..sort(
                (a, b) => (a.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
                  b.createdAt?.millisecondsSinceEpoch ?? 0,
                ),
              ),
        );
  }

  static Future<void> review({
    required String applicationId,
    required String status,
    String? note,
  }) => _applications.doc(applicationId).update({
    'status': status,
    'reviewerNote': note?.trim().isEmpty ?? true ? null : note!.trim(),
    'reviewedAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
