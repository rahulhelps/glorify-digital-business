import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/wallet/domain/repositories/withdraw_repository.dart';
import 'dart:developer' as dev;

class WithdrawRepositoryImpl implements WithdrawRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  WithdrawRepositoryImpl({required this.firestore, required this.networkInfo});

  @override
  Future<void> submitWithdrawRequest({
    required String uid,
    required String userName,
    required double amount,
    required String method,
    required String accountNumber,
    required double earning,
    required double voucher,
    required double referral,
    String? bankName,
  }) async {
    // Check internet
    if (!await networkInfo.isConnected) {
      throw 'ইন্টারনেট সংযোগ নেই';
    }

    // Read fresh user data from Firestore
    final userDoc = await firestore.collection('users').doc(uid).get();
    final hasWithdrawnBefore =
        userDoc.data()?['hasWithdrawnBefore'] as bool? ?? false;

    final balanceMap = userDoc.data()?['balance'] as Map<String, dynamic>?;
    final dbEarning = (balanceMap?['earning'] as num?)?.toDouble() ?? 0.0;
    final dbVoucher = (balanceMap?['voucher'] as num?)?.toDouble() ?? 0.0;
    final dbReferral = (balanceMap?['referral'] as num?)?.toDouble() ?? 0.0;
    final totalBalance = dbEarning + dbVoucher + dbReferral;

    dev.log('🔥 [Withdraw] hasWithdrawnBefore: $hasWithdrawnBefore');
    dev.log('🔥 [Withdraw] amount: $amount, totalBalance: $totalBalance');

    // Minimum amount validation
    final double minimumAmount = hasWithdrawnBefore ? 100.0 : 20.0;

    if (amount < minimumAmount) {
      throw hasWithdrawnBefore
            ? 'সর্বনিম্ন উত্তোলন ৳১০০'
            : 'সর্বনিম্ন উত্তোলন ৳২০ (প্রথমবার বিশেষ সুবিধা)';
    }

    if (amount > totalBalance) {
      throw 'পর্যাপ্ত ব্যালেন্স নেই। আপনার ব্যালেন্স: ৳${totalBalance.toStringAsFixed(2)}';
    }

    // Deduct balance (earning → referral → voucher)
    double remaining = amount;
    final Map<String, dynamic> balanceUpdate = {};

    if (remaining <= dbEarning) {
      balanceUpdate['balance.earning'] = FieldValue.increment(-remaining);
      remaining = 0;
    } else {
      balanceUpdate['balance.earning'] = FieldValue.increment(-dbEarning);
      remaining -= dbEarning;
      if (remaining <= dbReferral) {
        balanceUpdate['balance.referral'] = FieldValue.increment(-remaining);
        remaining = 0;
      } else {
        balanceUpdate['balance.referral'] = FieldValue.increment(-dbReferral);
        remaining -= dbReferral;
        balanceUpdate['balance.voucher'] = FieldValue.increment(-remaining);
      }
    }

    balanceUpdate['balance.total'] = FieldValue.increment(-amount);
    balanceUpdate['balance.withdrawn'] = FieldValue.increment(amount);

    // Mark hasWithdrawnBefore = true (one-time flag)
    balanceUpdate['hasWithdrawnBefore'] = true;

    final batch = firestore.batch();

    // Update user balance + flag
    batch.update(firestore.collection('users').doc(uid), balanceUpdate);

    // Calculate 3% processing fee
    final double fee = amount * 0.03;
    final double netAmount = amount - fee;

    // Save withdraw request
    final withdrawRef = firestore.collection('withdraw_requests').doc();
    batch.set(withdrawRef, {
      'uid': uid,
      'userName': userName,
      'amount': netAmount,
      'requestedAmount': amount,
      'feeAmount': fee,
      'method': method,
      'accountNumber': accountNumber,
      'bankName': bankName ?? '',
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
      'processedAt': null,
      'isFirstWithdraw': !hasWithdrawnBefore,
    });

    try {
      await batch.commit();
      dev.log('✅ [Withdraw] Success. hasWithdrawnBefore set to true');
    } catch (e) {
      dev.log('❌ [Withdraw] Error: $e');
      throw 'সার্ভার ত্রুটি। আবার চেষ্টা করুন।';
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchWithdrawHistory(String uid) {
    dev.log('🔥 [WithdrawHistory] Loading for uid: $uid');
    return firestore
        .collection('withdraw_requests')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          // Sort locally by requestedAt descending
          requests.sort((a, b) {
            final aTime =
                (a['requestedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime =
                (b['requestedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bTime.compareTo(aTime);
          });

          dev.log('✅ [WithdrawHistory] Found ${requests.length} requests');
          return requests;
        });
  }
}
