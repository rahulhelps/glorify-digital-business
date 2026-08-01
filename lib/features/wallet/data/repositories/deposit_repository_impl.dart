import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/features/wallet/domain/repositories/deposit_repository.dart';
import 'dart:developer' as dev;

class DepositRepositoryImpl implements DepositRepository {
  final FirebaseFirestore db;

  DepositRepositoryImpl({required this.db});

  @override
  Future<void> submitDeposit({
    required String uid,
    required String userName,
    required String userEmail,
    required double amount,
    required String method,
    required String transactionId,
    required DateTime submittedAt,
  }) async {
    final requestId = db.collection('deposit_requests').doc().id;
    dev.log('🔥 [Deposit] Payment submitted: $amount via $method');

    await db.collection('deposit_requests').doc(requestId).set({
      'uid': uid,
      'userName': userName,
      'userEmail': userEmail,
      'amount': amount,
      'method': method,
      'transactionId': transactionId,
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'approvedAt': null,
    });

    dev.log('✅ [Deposit] Request saved: $requestId');
  }

  @override
  Stream<List<Map<String, dynamic>>> watchDepositHistory(String uid) {
    dev.log('🔥 [Deposit] Loading history for uid: $uid');
    return db
        .collection('deposit_requests')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          requests.sort((a, b) {
            final aTime =
                (a['submittedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime =
                (b['submittedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bTime.compareTo(aTime);
          });

          dev.log('✅ [Deposit] Found ${requests.length} deposit requests');
          return requests;
        });
  }

  @override
  Future<void> approveDeposit(
    String requestId,
    String uid,
    double amount,
  ) async {
    final doc = await db.collection('deposit_requests').doc(requestId).get();
    if (doc.data()?['status'] != 'pending') {
      throw Exception('Already processed');
    }

    final batch = db.batch();

    batch.update(db.collection('deposit_requests').doc(requestId), {
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });

    batch.update(db.collection('users').doc(uid), {
      'balance.earning': FieldValue.increment(amount),
      'balance.total': FieldValue.increment(amount),
    });

    final historyRef = db.collection('income_history').doc();
    batch.set(historyRef, {
      'uid': uid,
      'amount': amount,
      'type': 'deposit',
      'description': 'ব্যালেন্স ডিপোজিট অনুমোদিত',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
