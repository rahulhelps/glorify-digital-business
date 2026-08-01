import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherHistoryModel {
  final String id;
  final String uid;
  final String type; // 'purchase' or 'redeem'
  final num amount;
  final String voucherCode;
  final String title;
  final DateTime createdAt;

  VoucherHistoryModel({
    required this.id,
    required this.uid,
    required this.type,
    required this.amount,
    required this.voucherCode,
    required this.title,
    required this.createdAt,
  });

  factory VoucherHistoryModel.fromJson(Map<String, dynamic> json, String id) {
    return VoucherHistoryModel(
      id: id,
      uid: json['uid'] ?? '',
      type: json['type'] ?? 'purchase',
      amount: json['amount'] ?? 0,
      voucherCode: json['voucherCode'] ?? '',
      title: json['title'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'type': type,
      'amount': amount,
      'voucherCode': voucherCode,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
