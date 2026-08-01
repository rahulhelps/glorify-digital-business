import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/features/recharge/domain/repositories/recharge_repository.dart';

class RechargeRepositoryImpl implements RechargeRepository {
  final FirebaseFirestore _db;

  RechargeRepositoryImpl({required FirebaseFirestore db}) : _db = db;

  @override
  Stream<double> watchRechargeBalance(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return 0.0;
      final data = snap.data();
      if (data == null) return 0.0;
      final balance = data['balance'] as Map<String, dynamic>?;
      if (balance == null) return 0.0;
      return (balance['recharge_balance'] ?? 0).toDouble();
    });
  }

  @override
  Future<void> submitRechargeRequest({
    required String uid,
    required String userName,
    required String phone,
    required String operator,
    required String connectionType,
    required double amount,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection('users').doc(uid);
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception('User not found');
        }

        final balanceMap = userSnapshot.data()?['balance'] as Map<String, dynamic>?;
        final currentRechargeBalance = (balanceMap?['recharge_balance'] as num?)?.toDouble() ?? 0.0;

        if (amount > currentRechargeBalance) {
          throw 'পর্যাপ্ত রিচার্জ ব্যালেন্স নেই। আপনার ব্যালেন্স: ৳${currentRechargeBalance.toStringAsFixed(2)}';
        }

        // Deduct from recharge balance
        transaction.update(userRef, {
          'balance.recharge_balance': FieldValue.increment(-amount),
        });

        // Save pending request
        final docRef = _db.collection('recharge_requests').doc();
        transaction.set(docRef, {
          'id': docRef.id,
          'uid': uid,
          'userName': userName,
          'phone': phone,
          'operator': operator,
          'connectionType': connectionType,
          'amount': amount,
          'status': 'pending',
          'submittedAt': FieldValue.serverTimestamp(),
        });
      });
      dev.log('✅ [Recharge] Request submitted securely');
    } catch (e) {
      dev.log('❌ [Recharge] Submit error: $e');
      rethrow;
    }
  }

  @override
  Future<void> transferFromMainWallet({
    required String uid,
    required double amount,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection('users').doc(uid);
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception('User not found');
        }

        final balanceMap = userSnapshot.data()?['balance'] as Map<String, dynamic>?;
        final dbEarning = (balanceMap?['earning'] as num?)?.toDouble() ?? 0.0;
        final dbVoucher = (balanceMap?['voucher'] as num?)?.toDouble() ?? 0.0;
        final dbReferral = (balanceMap?['referral'] as num?)?.toDouble() ?? 0.0;
        final totalBalance = dbEarning + dbVoucher + dbReferral;

        if (amount > totalBalance) {
          throw 'পর্যাপ্ত মেইন ব্যালেন্স নেই। আপনার ব্যালেন্স: ৳${totalBalance.toStringAsFixed(2)}';
        }

        // Deduct balance (earning -> referral -> voucher)
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

        balanceUpdate['balance.recharge_balance'] = FieldValue.increment(amount);

        transaction.update(userRef, balanceUpdate);
      });
      dev.log('✅ [Recharge] Wallet transfer complete: ৳$amount');
    } catch (e) {
      dev.log('❌ [Recharge] Transfer error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchRechargeHistory(String uid) {
    return _db
        .collection('recharge_requests')
        .where('uid', isEqualTo: uid)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          requests.sort((a, b) {
            final aTime = _readTimestamp(a);
            final bTime = _readTimestamp(b);
            return bTime.compareTo(aTime);
          });

          return requests;
        });
  }

  DateTime _readTimestamp(Map<String, dynamic> data) {
    final raw = data['submittedAt'] ?? data['timestamp'];
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Future<void> submitRechargeDeposit({
    required String uid,
    required String userName,
    required String userEmail,
    required double amount,
    required String method,
    required String transactionId,
    required DateTime submittedAt,
  }) async {
    try {
      final docRef = _db.collection('recharge_deposits').doc();
      await docRef.set({
        'id': docRef.id,
        'uid': uid,
        'userName': userName,
        'userEmail': userEmail,
        'amount': amount,
        'method': method,
        'transactionId': transactionId,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'targetWallet': 'recharge_balance',
      });
      dev.log('✅ [Recharge] Deposit submitted: ${docRef.id}');
    } catch (e) {
      dev.log('❌ [Recharge] Deposit error: $e');
      rethrow;
    }
  }
}
