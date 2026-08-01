import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/wallet/data/models/voucher_history_model.dart';
import 'package:global_earn/features/wallet/data/models/voucher_model.dart';
import 'package:global_earn/features/wallet/domain/repositories/voucher_repository.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  VoucherRepositoryImpl({required this.firestore, required this.networkInfo});

  @override
  Future<String> purchaseVoucher({
    required String uid,
    required num amount,
  }) async {
    log('🔥 [Voucher] Attempting to purchase voucher: $amount for user: $uid');

    if (!await networkInfo.isConnected) {
      throw Exception(
        'ইন্টারনেট সংযোগ নেই। অনুগ্রহ করে আপনার সংযোগ পরীক্ষা করুন।',
      );
    }

    // Minimum ৳100
    if (amount < 100) {
      throw Exception('সর্বনিম্ন ভাউচার পরিমাণ ৳১০০');
    }

    try {
      final userDoc = await firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');

      final userData = userDoc.data()!;
      final balanceMap = userData['balance'] as Map<String, dynamic>;
      final earning = (balanceMap['earning'] as num?)?.toDouble() ?? 0.0;
      final voucher = (balanceMap['voucher'] as num?)?.toDouble() ?? 0.0;
      final referral = (balanceMap['referral'] as num?)?.toDouble() ?? 0.0;
      final totalBalance = earning + voucher + referral;

      log('🔥 [Voucher] Purchase amount: $amount, totalBalance: $totalBalance');

      if (amount > totalBalance) {
        log('❌ [Voucher] Insufficient balance');
        throw Exception(
          'পর্যাপ্ত ব্যালেন্স নেই। আপনার ব্যালেন্স: ৳${totalBalance.toStringAsFixed(2)}',
        );
      }

      log('✅ [Voucher] Balance OK — creating voucher');

      final batch = firestore.batch();
      final userRef = firestore.collection('users').doc(uid);
      final voucherRef = firestore.collection('vouchers').doc();
      final historyRef = firestore.collection('voucher_history').doc();

      // Create unique voucher code
      final code =
          'LC-${DateTime.now().millisecondsSinceEpoch}-${uid.substring(0, 4).toUpperCase()}';

      // Deduct from total balance (earning → referral → voucher order)
      double remaining = amount.toDouble();
      final Map<String, dynamic> balanceUpdate = {};

      if (remaining <= earning) {
        balanceUpdate['balance.earning'] = FieldValue.increment(-remaining);
        remaining = 0;
      } else {
        balanceUpdate['balance.earning'] = FieldValue.increment(-earning);
        remaining -= earning;
        if (remaining <= referral) {
          balanceUpdate['balance.referral'] = FieldValue.increment(-remaining);
          remaining = 0;
        } else {
          balanceUpdate['balance.referral'] = FieldValue.increment(-referral);
          remaining -= referral;
          balanceUpdate['balance.voucher'] = FieldValue.increment(-remaining);
        }
      }

      balanceUpdate['balance.total'] = FieldValue.increment(-amount);

      // 1. Deduct from user balance
      batch.update(userRef, balanceUpdate);

      // 2. Save to vouchers collection
      batch.set(voucherRef, {
        'code': code,
        'amount': amount,
        'isUsed': false,
        'usedBy': null,
        'usedAt': null,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Add to voucher_history
      batch.set(historyRef, {
        'uid': uid,
        'type': 'purchase',
        'amount': amount,
        'voucherCode': code,
        'title': 'ভাউচার কেনা হয়েছে',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      log('✅ [Voucher] Voucher created: $code');
      return code;
    } catch (e) {
      log('❌ [Voucher] Voucher purchase failed: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('ভাউচার কিনতে সমস্যা হয়েছে: $e');
    }
  }

  @override
  Future<void> redeemVoucher({
    required String uid,
    required String code,
  }) async {
    log('🔥 [Voucher] Redeeming code: $code for user: $uid');

    if (!await networkInfo.isConnected) {
      throw Exception(
        'ইন্টারনেট সংযোগ নেই। অনুগ্রহ করে আপনার সংযোগ পরীক্ষা করুন।',
      );
    }

    try {
      final voucherQuery = await firestore
          .collection('vouchers')
          .where('code', isEqualTo: code)
          .where('isUsed', isEqualTo: false)
          .get();

      if (voucherQuery.docs.isEmpty) {
        throw Exception('অবৈধ বা ব্যবহৃত ভাউচার কোড');
      }

      final voucherDoc = voucherQuery.docs.first;
      final voucherAmount = voucherDoc.data()['amount'] ?? 0;

      final batch = firestore.batch();
      final userRef = firestore.collection('users').doc(uid);
      final voucherRef = voucherDoc.reference;
      final historyRef = firestore.collection('voucher_history').doc();

      // Update voucher status
      batch.update(voucherRef, {
        'isUsed': true,
        'usedBy': uid,
        'usedAt': FieldValue.serverTimestamp(),
      });

      // Update user balance
      batch.update(userRef, {
        'balance.voucher': FieldValue.increment(voucherAmount),
        'balance.total': FieldValue.increment(voucherAmount),
      });

      // Add history record
      batch.set(historyRef, {
        'uid': uid,
        'type': 'redeem',
        'amount': voucherAmount,
        'voucherCode': code,
        'title': 'ভাউচার রিডিম',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      log('✅ [Voucher] Redeemed: $voucherAmount added');
    } catch (e) {
      log('❌ [Voucher] Voucher redeem failed: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('ভাউচার রিডিম করতে সমস্যা হয়েছে: $e');
    }
  }

  @override
  Stream<List<VoucherHistoryModel>> getVoucherHistory({
    required String uid,
    String? type,
    int? limit,
  }) {
    log(
      '🔥 [Voucher] Fetching voucher history for user: $uid ${type != null ? "type: $type" : ""}',
    );

    var query = firestore
        .collection('voucher_history')
        .where('uid', isEqualTo: uid);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return VoucherHistoryModel.fromJson(doc.data(), doc.id);
      }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  @override
  Stream<List<VoucherModel>> getMyPurchasedVouchers(String uid) {
    log('🔥 [Voucher] Fetching purchased vouchers for user: $uid');

    return firestore
        .collection('vouchers')
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return VoucherModel.fromJson(doc.data(), doc.id);
          }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
  }
}
