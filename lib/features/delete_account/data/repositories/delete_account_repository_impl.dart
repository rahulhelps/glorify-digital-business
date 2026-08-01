import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/delete_account/domain/repositories/delete_account_repository.dart';

class DeleteAccountRepositoryImpl implements DeleteAccountRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final NetworkInfo _networkInfo;

  DeleteAccountRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required NetworkInfo networkInfo,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _networkInfo = networkInfo;

  @override
  Future<void> deleteAccount({required String password}) async {
    if (!await _networkInfo.isConnected) {
      throw 'ইন্টারনেট সংযোগ নেই';
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) throw 'ব্যবহারকারী খুঁজে পাওয়া যায়নি';
    final uid = user.uid;

    try {
      dev.log('🔥 [DeleteAccount] Re-authenticating...');
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      dev.log('✅ [DeleteAccount] Re-auth success');

      dev.log('🔥 [DeleteAccount] Deleting Firestore data...');
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(_firestore.collection('users').doc(uid));

      // Delete user's job posts
      final jobPosts = await _firestore
          .collection('job_posts')
          .where('postedBy', isEqualTo: uid)
          .get();
      for (final doc in jobPosts.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's submissions
      final submissions = await _firestore
          .collection('job_submissions')
          .where('submittedBy', isEqualTo: uid)
          .get();
      for (final doc in submissions.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's reviews
      final reviews = await _firestore
          .collection('reviews')
          .where('uid', isEqualTo: uid)
          .get();
      for (final doc in reviews.docs) {
        batch.delete(doc.reference);
      }

      // Delete voucher history
      final voucherHistory = await _firestore
          .collection('voucher_history')
          .where('uid', isEqualTo: uid)
          .get();
      for (final doc in voucherHistory.docs) {
        batch.delete(doc.reference);
      }

      // Delete withdraw requests
      final withdraws = await _firestore
          .collection('withdraw_requests')
          .where('uid', isEqualTo: uid)
          .get();
      for (final doc in withdraws.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      dev.log('✅ [DeleteAccount] Firestore data deleted');

      dev.log('🔥 [DeleteAccount] Deleting Firebase Auth account...');
      await user.delete();
      dev.log('✅ [DeleteAccount] Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        dev.log('❌ [DeleteAccount] Wrong password');
        throw 'পাসওয়ার্ড ভুল হয়েছে';
      }
      dev.log('❌ [DeleteAccount] Error: ${e.code}');
      throw 'একাউন্ট মুছতে সমস্যা হয়েছে, আবার চেষ্টা করুন';
    } catch (e) {
      dev.log('❌ [DeleteAccount] Error: $e');
      throw 'একাউন্ট মুছতে সমস্যা হয়েছে, আবার চেষ্টা করুন';
    }
  }
}
