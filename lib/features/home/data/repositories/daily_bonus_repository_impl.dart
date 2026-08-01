import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_earn/core/constants/app_constants.dart';
import 'package:global_earn/features/home/domain/repositories/daily_bonus_repository.dart';
import 'package:global_earn/core/utils/time_utils.dart';
import 'dart:developer' as developer;

class DailyBonusRepositoryImpl implements DailyBonusRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DailyBonusRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  @override
  Stream<Map<String, dynamic>?> streamDailyRecord(String date) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    developer.log('🔥 [DailyBonus] Listening for date: $date');

    return _firestore
        .collection('daily_bonus_claims')
        .doc(uid)
        .collection('records')
        .doc(date)
        .snapshots()
        .map((doc) => doc.data());
  }

  @override
  Future<void> claimDailyBonus(String date) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not logged in');

      final networkUtc = await TimeUtils.getNetworkUtcTime();
      final currentBstDate = networkUtc.add(const Duration(hours: 6));
      final secureDateStr = '${currentBstDate.year}-${currentBstDate.month.toString().padLeft(2, '0')}-${currentBstDate.day.toString().padLeft(2, '0')}';

      developer.log('🔥 [DailyBonus] Starting claim for uid: $uid');
      developer.log('🔥 [DailyBonus] Amount: ৳30');

      final claimRef = _firestore
          .collection('daily_bonus_claims')
          .doc(uid)
          .collection('records')
          .doc(secureDateStr);

      final doc = await claimRef.get();

      if (doc.data()?['bonusClaimed'] == true) {
        throw Exception('এই বোনাস ইতোমধ্যে নেওয়া হয়েছে');
      }

      final verifiedCount = doc.data()?['level1VerifiedToday'] as int? ?? 0;
      if (verifiedCount < 3) {
        throw Exception('এখনো ৩ জন verified হয়নি');
      }

      final batch = _firestore.batch();

      // Add to user balance
      batch.update(_firestore.collection('users').doc(uid), {
        'balance.earning': FieldValue.increment(30),
        'balance.total': FieldValue.increment(30),
      });

      // Mark as claimed
      batch.set(claimRef, {
        'bonusClaimed': true,
        'claimedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add income history
      final historyRef = _firestore.collection('income_history').doc();
      batch.set(historyRef, {
        'uid': uid,
        'amount': 30,
        'type': 'daily_bonus',
        'description': 'ডেইলি বোনাস',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      developer.log('✅ [DailyBonus] Batch committed — balance updated');
    } catch (e) {
      developer.log('❌ [DailyBonus] Error: $e');
      rethrow;
    }
  }

  @override
  Future<int> getTodayVerifiedCount(String referCode) async {
    if (referCode.isEmpty) return 0;

    // Fetch network time to prevent device clock tampering
    final networkUtc = await TimeUtils.getNetworkUtcTime();
    final nowBst = networkUtc.add(const Duration(hours: 6));

    // Start of today at midnight Bangladesh time, converted to UTC for Firestore
    final todayStartBst = DateTime(nowBst.year, nowBst.month, nowBst.day);
    final todayStartUtc = todayStartBst.subtract(const Duration(hours: 6)).toUtc();

    developer.log(
      '🔥 [DailyBonus] Getting today verified count for: $referCode (since $todayStartUtc UTC)',
    );

    final query = await _firestore
        .collection('users')
        .where('referredBy', isEqualTo: referCode)
        .where('subscriptionStatus', whereIn: SubscriptionStatus.strictPremium320Statuses)
        .get();

    // Filter locally by joinedAt >= start of today (UTC equivalent)
    final todayVerified = query.docs.where((doc) {
      final joinedAt = (doc.data()['joinedAt'] as Timestamp?)?.toDate();
      return joinedAt != null && joinedAt.isAfter(todayStartUtc);
    }).length;

    developer.log('✅ [DailyBonus] Today verified: $todayVerified');
    return todayVerified;
  }
}
