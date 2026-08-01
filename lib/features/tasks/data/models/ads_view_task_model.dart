import 'package:cloud_firestore/cloud_firestore.dart';

class AdsViewTaskModel {
  final String taskId;
  final String userId;
  final String imageUrl;
  final String imageHash;
  final String status; // 'pending' | 'approved' | 'rejected'
  final double amount;
  final DateTime submittedAt;

  const AdsViewTaskModel({
    required this.taskId,
    required this.userId,
    required this.imageUrl,
    required this.imageHash,
    required this.status,
    required this.amount,
    required this.submittedAt,
  });

  factory AdsViewTaskModel.fromJson(Map<String, dynamic> json, String id) {
    return AdsViewTaskModel(
      taskId: id,
      userId: json['userId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      imageHash: json['imageHash'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      submittedAt:
          (json['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'imageUrl': imageUrl,
        'imageHash': imageHash,
        'status': status,
        'amount': amount,
        'submittedAt': FieldValue.serverTimestamp(),
      };
}
