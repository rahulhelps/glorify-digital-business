import 'package:cloud_firestore/cloud_firestore.dart';

class DownlineUserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String referCode;
  final String referredBy;
  final String subscriptionStatus; // 'none', 'pending', 'plan_320', '320'
  final DateTime joinedAt;
  final int level;
  final String? profileImageUrl;

  const DownlineUserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.referCode,
    required this.referredBy,
    required this.subscriptionStatus,
    required this.joinedAt,
    required this.level,
    this.profileImageUrl,
  });

  /// True if user is on the ৳320 Full Premium plan.
  bool get hasAnyActivePlan {
    final s = subscriptionStatus.trim();
    return s == 'plan_320' || s == '320';
  }

  // ── Backward-compatibility shims ───────────────────────────────────
  /// Any active subscriber. Kept for existing callers.
  bool get isPremium => hasAnyActivePlan;
  bool get isVerified => hasAnyActivePlan;
  bool get isPending => subscriptionStatus.trim() == 'pending';
  bool get isNormal  => !hasAnyActivePlan && !isPending;

  factory DownlineUserModel.fromFirestore(
    Map<String, dynamic> data,
    String docId,
    int level,
  ) {
    return DownlineUserModel(
      uid: docId,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      referCode: data['referCode'] as String? ?? '',
      referredBy: data['referredBy'] as String? ?? '',
      subscriptionStatus: data['subscriptionStatus']?.toString().trim() ?? 'none',
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      level: level,
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }
}
