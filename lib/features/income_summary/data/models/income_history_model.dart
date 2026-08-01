import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeHistoryModel {
  final String id;
  final String uid;
  final double amount;
  final String type;
  final String description;
  final DateTime createdAt;

  const IncomeHistoryModel({
    required this.id,
    required this.uid,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory IncomeHistoryModel.fromJson(Map<String, dynamic> json, String id) {
    return IncomeHistoryModel(
      id: id,
      uid: json['uid'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? 'unknown',
      description: json['description'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
