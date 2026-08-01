import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/features/home/domain/repositories/subscription_repository.dart';
import 'package:global_earn/features/network/domain/repositories/referral_bonus_repository.dart';
import 'dart:developer' as dev;

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final FirebaseFirestore _firestore;
  final ReferralBonusRepository _referralBonusRepository;

  SubscriptionRepositoryImpl({
    FirebaseFirestore? firestore,
    required ReferralBonusRepository referralBonusRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _referralBonusRepository = referralBonusRepository;

  @override
  Future<void> savePaymentRequest({
    required String uid,
    required String userName,
    required String userEmail,
    required double amount,
    required String requestedPlan,
    required String method,
    required String transactionId,
    required DateTime submittedAt,
  }) async {
    dev.log(
      '🔥 [Subscription] Saving payment request...',
      name: 'Subscription',
    );
    try {
      final safeUid = uid.trim();
      final safeUserName = userName.trim();
      final safeUserEmail = userEmail.trim();
      final safePlan = requestedPlan.trim();
      final safeMethod = method.trim();
      final safeTransactionId = transactionId.trim();

      if (safeUid.isEmpty || safeTransactionId.isEmpty) {
        throw Exception('Invalid payment submission data');
      }
      if (safePlan != 'plan_320') {
        throw Exception('Invalid requested plan: $safePlan');
      }

      final fee = 0.0;
      final totalPaid = amount + fee;

      await _firestore.collection('subscription_requests').add({
        'uid': safeUid,
        'userName': safeUserName,
        'userEmail': safeUserEmail,
        'paymentAmount': amount,
        'requestedPlan': safePlan,
        'plan_type': safePlan,
        'fee': fee,
        'totalPaid': totalPaid,
        'method': safeMethod,
        'transactionId': safeTransactionId,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'approvedAt': null,
      });

      await _firestore.collection('users').doc(safeUid).update({
        'subscriptionStatus': 'pending',
        'requestedPlan': safePlan,
        'plan_type': safePlan,
        'paymentAmount': amount,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      dev.log(
        '✅ [Subscription] Payment request saved: $safeTransactionId',
        name: 'Subscription',
      );
    } catch (e) {
      dev.log('❌ [Subscription] Error: $e', name: 'Subscription');
      rethrow;
    }
  }

  @override
  Future<String?> checkPendingRequest(String uid) async {
    dev.log(
      '🔥 [Subscription] Checking status for uid: $uid',
      name: 'Subscription',
    );
    try {
      final query = await _firestore
          .collection('subscription_requests')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      final status = query.docs.isNotEmpty ? 'pending' : null;
      dev.log('✅ [Subscription] Status: $status', name: 'Subscription');
      return status;
    } catch (e) {
      dev.log('❌ [Subscription] Error: $e', name: 'Subscription');
      return null;
    }
  }

  @override
  Future<void> approveSubscription(String requestId, String uid) async {
    dev.log(
      '🔥 [Subscription] Approving subscription for uid: $uid',
      name: 'Subscription',
    );
    try {
      // 1. Check bonusDistributed flag
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.data()?['bonusDistributed'] == true) {
        dev.log(
          '⚠️ [Referral] Bonus already distributed for $uid — skipping',
          name: 'Referral',
        );
        throw Exception('Bonus already distributed');
      }

      // 2. Update subscription_requests status
      final batch = _firestore.batch();
      batch.update(
        _firestore.collection('subscription_requests').doc(requestId),
        {'status': 'approved', 'approvedAt': FieldValue.serverTimestamp()},
      );

      // 3. Update user subscriptionStatus
      batch.update(_firestore.collection('users').doc(uid), {
        'subscriptionStatus': 'plan_320',
      });

      String? currentReferCode = userDoc.data()?['referredBy'];
      int level = 1;

      while (currentReferCode != null &&
          currentReferCode.isNotEmpty &&
          level <= 10) {
        final query = await _firestore
            .collection('users')
            .where('referCode', isEqualTo: currentReferCode)
            .limit(1)
            .get();
        if (query.docs.isEmpty) break;

        final uplineDoc = query.docs.first;
        batch.update(_firestore.collection('users').doc(uplineDoc.id), {
          'team.level${level}Business': FieldValue.increment(1),
        });

        if (level == 1) {
          final today = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.now().toUtc().add(const Duration(hours: 6)));
          final dailyRef = _firestore
              .collection('daily_bonus_claims')
              .doc(uplineDoc.id)
              .collection('records')
              .doc(today);

          // Calculate BD midnight
          final now = DateTime.now().toUtc().add(const Duration(hours: 6));
          final midnight = DateTime(now.year, now.month, now.day + 1);

          batch.set(dailyRef, {
            'date': today,
            'level1VerifiedToday': FieldValue.increment(1),
            'required': 3,
            'bonusClaimed': false,
            'expiresAt': Timestamp.fromDate(midnight),
          }, SetOptions(merge: true));
        }

        currentReferCode = uplineDoc.data()['referredBy'] as String?;
        level++;
      }

      await batch.commit();
      dev.log(
        '✅ [Subscription] Batch committed for approval',
        name: 'Subscription',
      );

      // 4. Distribute referral bonus (with guard inside)
      await _referralBonusRepository.distributeReferralBonus(uid);
    } catch (e) {
      dev.log(
        '❌ [Subscription] Error in approveSubscription: $e',
        name: 'Subscription',
      );
      rethrow;
    }
  }
}
