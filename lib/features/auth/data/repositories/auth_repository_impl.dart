import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/core/constants/app_constants.dart';
import 'package:global_earn/core/errors/invalid_refer_code_exception.dart';
import 'package:global_earn/features/auth/data/models/balance_model.dart';
import 'package:global_earn/features/auth/data/models/team_model.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required NetworkInfo networkInfo,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _networkInfo = networkInfo;

  String _getFriendlyMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'অ্যাকাউন্ট পাওয়া যায়নি';
      case 'wrong-password':
        return 'পাসওয়ার্ড ভুল হয়েছে';
      case 'invalid-credential':
        return 'ইমেইল বা পাসওয়ার্ড ভুল';
      case 'email-already-in-use':
        return 'এই ইমেইল দিয়ে আগেই অ্যাকাউন্ট আছে';
      case 'weak-password':
        return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষর হতে হবে';
      case 'network-request-failed':
        return 'ইন্টারনেট সংযোগ নেই';
      case 'too-many-requests':
        return 'অনেকবার চেষ্টা হয়েছে, কিছুক্ষণ পর আবার চেষ্টা করুন';
      default:
        return 'কিছু একটা সমস্যা হয়েছে, আবার চেষ্টা করুন';
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (!await _networkInfo.isConnected) return null;
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromJson(doc.data()!);
        }
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<UserModel> login(String emailOrPhone, String password) async {
    debugPrint('🔥 [Login] Starting login...');
    if (!await _networkInfo.isConnected) {
      throw NetworkException('ইন্টারনেট সংযোগ নেই');
    }
    try {
      String loginEmail = emailOrPhone;

      // Detect input type
      if (!emailOrPhone.contains('@')) {
        // Treat as phone number
        debugPrint('🔥 [Login] Input is phone number, querying email...');
        final userQuery = await _firestore
            .collection('users')
            .where('phone', isEqualTo: emailOrPhone)
            .limit(1)
            .get();
        if (userQuery.docs.isEmpty) {
          throw Exception('অ্যাকাউন্ট পাওয়া যায়নি');
        }
        loginEmail = userQuery.docs.first.data()['email'] as String;
        debugPrint('✅ [Login] Found email for phone: $loginEmail');
      }

      debugPrint('🔥 [Login] Firebase Auth logging in...');
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );
      debugPrint('✅ [Login] User logged in: ${userCredential.user!.uid}');

      debugPrint('🔥 [Firestore] Reading user document...');
      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (!doc.exists) {
        throw Exception('User document not found');
      }
      debugPrint('✅ [Firestore] Document read successfully');
      return UserModel.fromJson(doc.data()!);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      throw Exception(_getFriendlyMessage(e.code));
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException: ${e.code} - ${e.message}');
      throw Exception('কিছু একটা সমস্যা হয়েছে, আবার চেষ্টা করুন');
    } on Exception catch (e) {
      debugPrint('❌ Known Exception: $e');
      if (e is NetworkException) throw Exception('ইন্টারনেট সংযোগ নেই');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      throw Exception('কিছু একটা সমস্যা হয়েছে, আবার চেষ্টা করুন');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<String> _generateUniqueReferCode() async {
    while (true) {
      final referCode = 'LC${_generateRandomString(6)}';
      final query = await _firestore
          .collection('users')
          .where('referCode', isEqualTo: referCode)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        return referCode;
      }
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? referredBy,
  }) async {
    debugPrint('🔥 [Register] Starting registration...');
    if (!await _networkInfo.isConnected) {
      throw NetworkException('ইন্টারনেট সংযোগ নেই');
    }
    try {
      final String finalReferredBy;

      if (referredBy == null || referredBy.trim().isEmpty) {
        finalReferredBy = AppConstants.defaultReferCode;
        debugPrint('🔥 [Register] No referCode → using default: $finalReferredBy');
      } else if (referredBy.trim() == AppConstants.defaultReferCode) {
        finalReferredBy = AppConstants.defaultReferCode;
        debugPrint('✅ [Register] Default referCode entered: $finalReferredBy');
      } else {
        debugPrint('🔥 [Register] Validating referCode: ${referredBy.trim()}');
        final query = await _firestore.collection('users')
            .where('referCode', isEqualTo: referredBy.trim())
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          debugPrint('❌ [Register] Invalid referCode: ${referredBy.trim()}');
          throw const InvalidReferCodeException('অবৈধ রেফার কোড। সঠিক রেফার কোড দিন।');
        }
        finalReferredBy = referredBy.trim();
        debugPrint('✅ [Register] Valid referCode: $finalReferredBy');
      }

      debugPrint('🔥 [Register] Firebase Auth creating user...');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      debugPrint('✅ [Register] User created: $uid');

      final referCode = await _generateUniqueReferCode();

      final newUser = UserModel(
        uid: uid,
        name: name,
        phone: phone,
        email: email,
        referCode: referCode,
        referredBy: finalReferredBy,
        subscriptionStatus: 'none',
        bonusDistributed: false,
        joinedAt: DateTime.now(),
        balance: BalanceModel(
          earning: 0,
          referral: 0,
          voucher: 0,
          withdrawn: 0,
          total: 0,
          rechargeBalance: 0,
        ),
        hasWithdrawnBefore: false,
        team: TeamModel(
          level1: 0,
          level1Business: 0,
          level2: 0,
          level2Business: 0,
          level3: 0,
          level3Business: 0,
          level4: 0,
          level4Business: 0,
          level5: 0,
          level5Business: 0,
          level6: 0,
          level6Business: 0,
          level7: 0,
          level7Business: 0,
          level8: 0,
          level8Business: 0,
          level9: 0,
          level9Business: 0,
          level10: 0,
          level10Business: 0,
        ),
      );

      final batch = _firestore.batch();
      final userRef = _firestore.collection('users').doc(uid);

      final userJson = newUser.toJson();
      userJson['joinedAt'] = FieldValue.serverTimestamp();
      batch.set(userRef, userJson);

      // IMPORTANT: Ensure Firestore has a user document with referCode == "123456"
      // This is the admin/owner account — all users without referCode become their downline
      // users/{adminUid}/referCode: "123456"
      String currentReferrer = finalReferredBy;
        for (int i = 1; i <= 10; i++) {
          final referrerQuery = await _firestore
              .collection('users')
              .where('referCode', isEqualTo: currentReferrer)
              .limit(1)
              .get();
          if (referrerQuery.docs.isEmpty) break;

          final referrerDoc = referrerQuery.docs.first;
          final referrerRef = referrerDoc.reference;

          batch.update(referrerRef, {'team.level$i': FieldValue.increment(1)});

          final nextReferrer = referrerDoc.data()['referredBy'] as String?;
          if (nextReferrer == null || nextReferrer.isEmpty) break;
          currentReferrer = nextReferrer;
        }

      debugPrint('🔥 [Firestore] Writing user document...');
      await batch.commit();
      debugPrint('✅ [Firestore] Document written successfully');

      // Welcome bonus removed as per requirements.
      // Instant ৳1 referral registration bonus removed as per requirements.

      return newUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      throw Exception(_getFriendlyMessage(e.code));
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException: ${e.code} - ${e.message}');
      throw Exception('কিছু একটা সমস্যা হয়েছে, আবার চেষ্টা করুন');
    } on Exception catch (e) {
      debugPrint('❌ Known Exception: $e');
      if (e is NetworkException) throw Exception('ইন্টারনেট সংযোগ নেই');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      throw Exception('কিছু একটা সমস্যা হয়েছে, আবার চেষ্টা করুন');
    }
  }

  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
