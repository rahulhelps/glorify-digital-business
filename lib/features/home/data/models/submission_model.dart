import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  final String submissionId;
  final String jobId;
  final String jobTitle;
  final String submittedBy;
  final String submitterName;
  final List<String> proofImages;
  final String proofText;
  final String status; // pending / approved / rejected
  final double reward;
  final DateTime submittedAt;

  const SubmissionModel({
    required this.submissionId,
    required this.jobId,
    required this.jobTitle,
    required this.submittedBy,
    required this.submitterName,
    required this.proofImages,
    required this.proofText,
    required this.status,
    required this.reward,
    required this.submittedAt,
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedDate;
    final raw = map['submittedAt'];
    if (raw is Timestamp) {
      parsedDate = raw.toDate();
    } else if (raw is String) {
      parsedDate = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    List<String> parsedImages = [];
    if (map['proofImages'] != null) {
      parsedImages = List<String>.from(map['proofImages']);
    } else if (map['proofImageUrl'] != null && map['proofImageUrl'].toString().isNotEmpty) {
      parsedImages = [map['proofImageUrl']];
    }

    return SubmissionModel(
      submissionId: docId ?? map['submissionId'] ?? '',
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      submittedBy: map['submittedBy'] ?? '',
      submitterName: map['submitterName'] ?? '',
      proofImages: parsedImages,
      proofText: map['proofText'] ?? '',
      status: map['status'] ?? 'pending',
      reward: (map['reward'] ?? 0.0).toDouble(),
      submittedAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() => {
    'submissionId': submissionId,
    'jobId': jobId,
    'jobTitle': jobTitle,
    'submittedBy': submittedBy,
    'submitterName': submitterName,
    'proofImages': proofImages,
    'proofText': proofText,
    'status': status,
    'reward': reward,
    'submittedAt': Timestamp.fromDate(submittedAt),
  };
}
