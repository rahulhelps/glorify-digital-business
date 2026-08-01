import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/core/constants/app_constants.dart';
import 'package:global_earn/features/network/domain/repositories/referral_bonus_repository.dart';
import 'dart:developer' as dev;

class ReferralBonusRepositoryImpl implements ReferralBonusRepository {
  final FirebaseFirestore _firestore;

  ReferralBonusRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> distributeReferralBonus(String newSubscriberUid) async {
    dev.log(
      '🔥 [Referral] Checking bonusDistributed flag for: $newSubscriberUid',
      name: 'Referral',
    );

    try {
      // 1. Check bonusDistributed flag
      final subscriberDoc = await _firestore
          .collection('users')
          .doc(newSubscriberUid)
          .get();
      if (!subscriberDoc.exists) {
        dev.log(
          '❌ [Referral] Subscriber not found: $newSubscriberUid',
          name: 'Referral',
        );
        return;
      }

      if (subscriberDoc.data()?['bonusDistributed'] == true) {
        dev.log(
          '⚠️ [Referral] Bonus already distributed for $newSubscriberUid — skipping',
          name: 'Referral',
        );
        return;
      }

      dev.log('✅ [Referral] Starting bonus distribution...', name: 'Referral');

      final subscriberData = subscriberDoc.data()!;
      String? currentReferCode = subscriberData['referredBy'];
      final subscriberName = subscriberData['name'] ?? '';

      final batch = _firestore.batch();
      int level = 1;

      while (currentReferCode != null &&
          currentReferCode.isNotEmpty &&
          level <= 10) {
        // Find upline by referCode
        final query = await _firestore
            .collection('users')
            .where('referCode', isEqualTo: currentReferCode)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          dev.log(
            '⚠️ [Referral] Upline with referCode $currentReferCode not found',
            name: 'Referral',
          );
          break;
        }

        final uplineDoc = query.docs.first;
        final uplineUid = uplineDoc.id;
        final bonus = AppConstants.referralBonusMap[level] ?? 0.0;

        // Increment business count on upline's team
        batch.update(_firestore.collection('users').doc(uplineUid), {
          'team.level${level}Business': FieldValue.increment(1),
        });

        if (bonus > 0) {
          // Add bonus to upline balance (referral field)
          batch.update(_firestore.collection('users').doc(uplineUid), {
            'balance.referral': FieldValue.increment(bonus),
            'balance.total': FieldValue.increment(bonus),
          });

          // Add income history record
          final historyRef = _firestore.collection('income_history').doc();
          batch.set(historyRef, {
            'uid': uplineUid,
            'amount': bonus,
            'type': 'referral_bonus',
            'fromUid': newSubscriberUid,
            'fromName': subscriberName,
            'level': level,
            'description': '$level নং জেনারেশন রেফার বোনাস',
            'createdAt': FieldValue.serverTimestamp(),
          });

          dev.log(
            '✅ [Referral] Level $level → $uplineUid gets ৳$bonus (referral balance)',
            name: 'Referral',
          );
        }

        // Move to next level
        currentReferCode = uplineDoc.data()['referredBy'];
        level++;
      }

      await batch.commit();
      dev.log(
        '✅ [Referral] Batch committed — ${level - 1} levels processed',
        name: 'Referral',
      );

      // 2. After successful batch commit → set flag
      await _firestore.collection('users').doc(newSubscriberUid).update({
        'bonusDistributed': true,
        'subscribedAt': FieldValue.serverTimestamp(),
      });
      dev.log(
        '✅ [Referral] bonusDistributed flag set to true',
        name: 'Referral',
      );
    } catch (e) {
      dev.log('❌ [Referral] Error: $e', name: 'Referral');
      rethrow;
    }
  }
}
