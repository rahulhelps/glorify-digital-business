import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/features/auth/data/models/balance_model.dart';
import 'package:global_earn/features/auth/data/models/team_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String referCode;
  final String referredBy;
  final DateTime joinedAt;
  final BalanceModel balance;
  final TeamModel team;
  final String subscriptionStatus;
  final bool bonusDistributed;
  final String? profileImageUrl;
  final String? bio;
  final int rankCount;
  final bool hasWithdrawnBefore;
  final DateTime? lastLuckyClaimAt;
  final bool verificationBannerShown;
  final DateTime? dateOfBirth;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.referCode,
    required this.referredBy,
    required this.subscriptionStatus,
    required this.bonusDistributed,
    required this.joinedAt,
    required this.balance,
    required this.team,
    this.profileImageUrl,
    this.bio,
    this.rankCount = 0,
    this.hasWithdrawnBefore = false,
    this.lastLuckyClaimAt,
    this.verificationBannerShown = false,
    this.dateOfBirth,
  });

  double get withdrawableBalance =>
      (balance.earning + balance.voucher + balance.referral).toDouble();

  // ── Canonical subscription helpers (source of truth) ────────────────────────
  /// True if the user has an active verified status (plan_320).
  bool get hasAnyActivePlan {
    final s = subscriptionStatus.trim();
    return s == 'plan_320' || s == '320';
  }

  /// Canonical verification check — true if the user has an 
  /// active verified status. Use this everywhere feature access is gated now.
  bool get isVerified => hasAnyActivePlan;

  // ── Backward-compatibility shims (delegate to canonical getters) ─────────────
  /// Alias: any verified user. Kept for existing callers.
  bool get isPremium => hasAnyActivePlan;
  bool get isPending => subscriptionStatus.trim() == 'pending';
  bool get isNormal  => !hasAnyActivePlan && !isPending;
  bool get isUnverified => !hasAnyActivePlan;

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    } else if (value is String) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now().toLocal();
    }
    return DateTime.now().toLocal();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      referCode: json['referCode'] ?? '',
      referredBy: json['referredBy'] ?? '',
      subscriptionStatus: json['subscriptionStatus']?.toString().trim() ?? 'none',
      bonusDistributed: json['bonusDistributed'] ?? false,
      joinedAt: _parseDate(json['joinedAt']),
      balance: json['balance'] != null
          ? BalanceModel.fromJson(json['balance'])
          : BalanceModel(
              earning: 0,
              referral: 0,
              voucher: 0,
              withdrawn: 0,
              total: 0,
            ),
      team: json['team'] != null
          ? TeamModel.fromJson(json['team'])
          : TeamModel(
              level1: 0,
              level1Business: 0,
              level2: 0,
              level2Business: 0,
              level3: 0,
              level3Business: 0,
              level4: 0,
              level4Business: 0,
              level5: 0,
              level5Business: 0,
              level6: 0,
              level6Business: 0,
              level7: 0,
              level7Business: 0,
              level8: 0,
              level8Business: 0,
              level9: 0,
              level9Business: 0,
              level10: 0,
              level10Business: 0,
            ),
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      rankCount: (json['rankCount'] ?? 0) as int,
      hasWithdrawnBefore: json['hasWithdrawnBefore'] as bool? ?? false,
      lastLuckyClaimAt: json['lastLuckyClaimAt'] != null ? _parseDate(json['lastLuckyClaimAt']) : null,
      verificationBannerShown: json['verificationBannerShown'] as bool? ?? false,
      dateOfBirth: json['dateOfBirth'] != null ? _parseDate(json['dateOfBirth']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'referCode': referCode,
      'referredBy': referredBy,
      'subscriptionStatus': subscriptionStatus,
      'bonusDistributed': bonusDistributed,
      'joinedAt': joinedAt,
      'balance': balance.toJson(),
      'team': team.toJson(),
      'profileImageUrl': profileImageUrl,
      if (bio != null) 'bio': bio,
      'rankCount': rankCount,
      'hasWithdrawnBefore': hasWithdrawnBefore,
      if (lastLuckyClaimAt != null) 'lastLuckyClaimAt': lastLuckyClaimAt,
      'verificationBannerShown': verificationBannerShown,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    };
  }
}
