import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';
import '../models/job.dart';
import 'firebase_backend_service.dart';

class ApplicationService {
  static final _applications = FirebaseFirestore.instance.collection('applications');

  static Future<void> submit({
    required Job job,
    required String name,
    required String email,
    required String phone,
    required String skills,
    required String profileUrl,
    required String coverLetter,
  }) async {
    if (!FirebaseBackendService.isReady) {
      throw StateError('Firebase is not configured. Complete the Firebase setup before submitting applications.');
    }
    final user = await FirebaseBackendService.ensureSignedIn();
    final existing = await _applications
        .where('applicantId', isEqualTo: user.uid)
        .where('jobId', isEqualTo: job.id)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw StateError('You have already applied for this job.');
    }
    await _applications.add({
      'applicantId': user.uid,
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
    });
  }

  static Stream<List<JobApplication>> mine() async* {
    if (!FirebaseBackendService.isReady) {
      yield const [];
      return;
    }
    final user = await FirebaseBackendService.ensureSignedIn();
    yield* _applications.where('applicantId', isEqualTo: user.uid).snapshots().map(
          (snapshot) => snapshot.docs.map(JobApplication.fromFirestore).toList()
            ..sort((a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0)
                .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0)),
        );
  }

  static Stream<List<JobApplication>> pendingForReview() async* {
    if (!FirebaseBackendService.isReady ||
        !await FirebaseBackendService.isReviewer()) {
      yield const [];
      return;
    }
    yield* _applications.where('status', isEqualTo: 'pending').snapshots().map(
          (snapshot) => snapshot.docs.map(JobApplication.fromFirestore).toList()
            ..sort((a, b) => (a.createdAt?.millisecondsSinceEpoch ?? 0)
                .compareTo(b.createdAt?.millisecondsSinceEpoch ?? 0)),
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
