import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/wallet/domain/repositories/transfer_repository.dart';
import 'dart:developer' as dev;
import 'dart:async';

class TransferRepositoryImpl implements TransferRepository {
  final FirebaseFirestore firestore;

  TransferRepositoryImpl({required this.firestore});

  @override
  Future<UserModel?> searchReceiver(String query) async {
    dev.log('🔥 [Transfer] Searching receiver: $query');

    // Search by referCode first
    var snapshot = await firestore
        .collection('users')
        .where('referCode', isEqualTo: query)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final user = UserModel.fromJson(snapshot.docs.first.data());
      dev.log('✅ [Transfer] Receiver found by referCode: ${user.name}');
      return user;
    }

    // Search by phone
    snapshot = await firestore
        .collection('users')
        .where('phone', isEqualTo: query)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final user = UserModel.fromJson(snapshot.docs.first.data());
      dev.log('✅ [Transfer] Receiver found by phone: ${user.name}');
      return user;
    }

    dev.log('❌ [Transfer] No receiver found for: $query');
    return null;
  }

  @override
  Future<String?> getUserPin(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    return doc.data()?['pin'] as String?;
  }

  @override
  Future<double> getEarningBalance(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null && data['balance'] != null) {
      return (data['balance']['earning'] ?? 0.0).toDouble();
    }
    return 0.0;
  }

  @override
  Stream<List<Map<String, dynamic>>> watchTransferHistory(String uid) {
    dev.log('🔥 [TransferHistory] Loading for uid: $uid');

    final controller = StreamController<List<Map<String, dynamic>>>();

    List<Map<String, dynamic>> lastSent = [];
    List<Map<String, dynamic>> lastReceived = [];

    void emitCombined() {
      final all = [...lastSent, ...lastReceived];
      all.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
      controller.add(all);
      dev.log(
        '✅ [TransferHistory] Sent: ${lastSent.length}, Received: ${lastReceived.length}',
      );
    }

    final sentSub = firestore
        .collection('transfer_history')
        .where('senderUid', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            lastSent = snapshot.docs
                .map((doc) => {...doc.data(), 'id': doc.id})
                .toList();
            emitCombined();
          },
          onError: (e) {
            dev.log('❌ [TransferHistory] Error: $e');
            if (!controller.isClosed) controller.addError(e);
          },
        );

    final receivedSub = firestore
        .collection('transfer_history')
        .where('receiverUid', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            lastReceived = snapshot.docs
                .map((doc) => {...doc.data(), 'id': doc.id})
                .toList();
            emitCombined();
          },
          onError: (e) {
            dev.log('❌ [TransferHistory] Error: $e');
            if (!controller.isClosed) controller.addError(e);
          },
        );

    controller.onCancel = () {
      sentSub.cancel();
      receivedSub.cancel();
    };

    return controller.stream;
  }

  @override
  Future<void> performTransfer({
    required String senderUid,
    required String receiverUid,
    required String senderName,
    required String receiverName,
    required double amount,
  }) async {
    final batch = firestore.batch();
    final senderRef = firestore.collection('users').doc(senderUid);
    final receiverRef = firestore.collection('users').doc(receiverUid);
    final transferRef = firestore.collection('transfer_history').doc();

    // Step 1: Read fresh balance from Firestore
    final userDoc = await senderRef.get();
    final balanceMap = userDoc.data()?['balance'] as Map<String, dynamic>?;
    final earning = (balanceMap?['earning'] as num?)?.toDouble() ?? 0.0;
    final voucher = (balanceMap?['voucher'] as num?)?.toDouble() ?? 0.0;
    final referral = (balanceMap?['referral'] as num?)?.toDouble() ?? 0.0;
    final totalBalance = earning + voucher + referral;

    dev.log('🔥 [Transfer] earning: $earning, voucher: $voucher, referral: $referral');
    dev.log('🔥 [Transfer] totalBalance: $totalBalance, amount: $amount');

    // Step 2: Correct validation
    if (amount < 100) {
      throw Exception('সর্বনিম্ন ট্রান্সফার ৳১০০');
    }
    if (amount > totalBalance) {
      throw Exception(
        'পর্যাপ্ত ব্যালেন্স নেই। আপনার মোট ব্যালেন্স: ৳${totalBalance.toStringAsFixed(2)}',
      );
    }
    dev.log('✅ [Transfer] Validation passed');

    // Deduct logic — earning first, then referral, then voucher
    double remaining = amount;
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
        remaining = 0;
      }
    }

    balanceUpdate['balance.total'] = FieldValue.increment(-amount);

    dev.log('✅ [Transfer] Balance update: $balanceUpdate');

    // Update sender balances
    batch.update(senderRef, balanceUpdate);

    // Add to receiver earning
    batch.update(receiverRef, {
      'balance.earning': FieldValue.increment(amount),
      'balance.total': FieldValue.increment(amount),
    });

    // Save transfer record
    batch.set(transferRef, {
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'senderName': senderName,
      'receiverName': receiverName,
      'amount': amount,
      'createdAt': FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit();
      dev.log('✅ [Transfer] Transfer complete: $amount to $receiverUid');
    } catch (e) {
      dev.log('❌ [Transfer] Error: $e');
      throw 'ট্রান্সফার প্রসেস করতে ত্রুটি হয়েছে। আবার চেষ্টা করুন।';
    }
  }
}
