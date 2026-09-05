import 'package:cloud_firestore/cloud_firestore.dart';

class JobApplication {
  final String id;
  final String jobId;
  final String jobTitle;
  final String company;
  final String status;
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String skills;
  final String profileUrl;
  final String coverLetter;
  final String? reviewerNote;
  final Timestamp? createdAt;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.status,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPhone,
    required this.skills,
    required this.profileUrl,
    required this.coverLetter,
    this.reviewerNote,
    this.createdAt,
  });

  factory JobApplication.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return JobApplication(
      id: doc.id,
      jobId: data['jobId'] as String? ?? '',
      jobTitle: data['jobTitle'] as String? ?? 'Job',
      company: data['company'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      applicantName: data['applicantName'] as String? ?? '',
      applicantEmail: data['applicantEmail'] as String? ?? '',
      applicantPhone: data['applicantPhone'] as String? ?? '',
      skills: data['skills'] as String? ?? '',
      profileUrl: data['profileUrl'] as String? ?? '',
      coverLetter: data['coverLetter'] as String? ?? '',
      reviewerNote: data['reviewerNote'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
