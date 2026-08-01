import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code;
  final num amount;
  final bool isUsed;
  final String? usedBy;
  final DateTime? usedAt;
  final DateTime createdAt;

  VoucherModel({
    required this.id,
    required this.code,
    required this.amount,
    required this.isUsed,
    this.usedBy,
    this.usedAt,
    required this.createdAt,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json, String id) {
    return VoucherModel(
      id: id,
      code: json['code'] ?? '',
      amount: json['amount'] ?? 0,
      isUsed: json['isUsed'] ?? false,
      usedBy: json['usedBy'],
      usedAt: (json['usedAt'] as Timestamp?)?.toDate(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'amount': amount,
      'isUsed': isUsed,
      'usedBy': usedBy,
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
