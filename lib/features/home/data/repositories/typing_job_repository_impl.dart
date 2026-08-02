import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_earn/core/constants/app_constants.dart';
import 'package:global_earn/features/home/domain/repositories/typing_job_repository.dart';
import 'dart:developer' as developer;

class TypingJobRepositoryImpl implements TypingJobRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TypingJobRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  @override
  Future<Map<String, dynamic>> getTypingJobProgress() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not logged in');

      // 1. Get user document to fetch referCode
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) throw Exception('User document not found');

      final referCode = userDoc.data()?['referCode'] as String?;
      if (referCode == null || referCode.isEmpty) {
        throw Exception('Refer code not found');
      }

      // 2. Count verified level 1 referrals
      final verifiedQuery = await _firestore
          .collection('users')
          .where('referredBy', isEqualTo: referCode)
          .where('subscriptionStatus', whereIn: SubscriptionStatus.activeStatuses)
          .get();

      int totalVerified = 0;
      for (final doc in verifiedQuery.docs) {
        final data = doc.data();
        final status = data['subscriptionStatus']?.toString().trim() ?? '';
        
        if (status == 'plan_320' || status == '320') {
          totalVerified += 1; // Premium users give 2 typing job sets
        } else {
          // Default fallback for unidentified/legacy cases
          totalVerified += 1;
        }
      }

      // 3. Get typing job progress
      final progressDoc = await _firestore
          .collection('typing_job_progress')
          .doc(uid)
          .get();
      int completedSets = 0;
      int totalEarned = 0;

      if (progressDoc.exists) {
        completedSets = progressDoc.data()?['completedQuizSets'] as int? ?? 0;
        totalEarned = progressDoc.data()?['totalEarned'] as int? ?? 0;
      }

      // Update progress doc with the latest totalVerified count
      await _firestore.collection('typing_job_progress').doc(uid).set({
        'totalVerifiedReferrals': totalVerified,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4. Get past sessions for history list
      final sessionsQuery = await _firestore
          .collection('typing_job_sessions')
          .doc(uid)
          .collection('sets')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final sessions = sessionsQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      return {
        'totalVerified': totalVerified,
        'completedSets': completedSets,
        'totalEarned': totalEarned,
        'sessions': sessions,
      };
    } catch (e) {
      developer.log('❌ [TypingJob] Error loading progress: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeMathSession({
    required int setNumber,
    required int correctCount,
    required List<Map<String, dynamic>> questions,
    required List<int> answers,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not logged in');

      developer.log('🔥 [TypingJob] Starting claim for uid: $uid');
      developer.log('🔥 [TypingJob] Amount: ৳$correctCount');

      final batch = _firestore.batch();

      // 1. Create a new session under typing_job_sessions/{uid}/sets/{setId}
      final sessionRef = _firestore
          .collection('typing_job_sessions')
          .doc(uid)
          .collection('sets')
          .doc();

      batch.set(sessionRef, {
        'setNumber': setNumber,
        'questions': questions,
        'answers': answers,
        'correctCount': correctCount,
        'earned': correctCount,
        'completed': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Update typing_job_progress
      final progressRef = _firestore.collection('typing_job_progress').doc(uid);
      batch.set(progressRef, {
        'completedQuizSets': FieldValue.increment(1),
        'totalEarned': FieldValue.increment(correctCount),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Award math bonus if any
      if (correctCount > 0) {
        // Add to user balance
        batch.update(_firestore.collection('users').doc(uid), {
          'balance.earning': FieldValue.increment(correctCount),
          'balance.total': FieldValue.increment(correctCount),
        });

        // Add income history
        final historyRef = _firestore.collection('income_history').doc();
        batch.set(historyRef, {
          'uid': uid,
          'amount': correctCount,
          'type': 'typing_job_math_bonus',
          'description': 'টাইপিং জব (ম্যাথ)',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      developer.log('✅ [TypingJob] Batch committed — balance updated');
    } catch (e) {
      developer.log('❌ [TypingJob] Error: $e');
      rethrow;
    }
  }
}
