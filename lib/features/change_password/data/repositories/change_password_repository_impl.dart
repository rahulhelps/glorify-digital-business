import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/change_password/domain/repositories/change_password_repository.dart';

class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  final FirebaseAuth _firebaseAuth;
  final NetworkInfo _networkInfo;

  ChangePasswordRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required NetworkInfo networkInfo,
  }) : _firebaseAuth = firebaseAuth,
       _networkInfo = networkInfo;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw 'ইন্টারনেট সংযোগ নেই';
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) throw 'ব্যবহারকারী খুঁজে পাওয়া যায়নি';

    try {
      dev.log('🔥 [ChangePassword] Re-authenticating...');
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      dev.log('✅ [ChangePassword] Re-auth success');

      dev.log('🔥 [ChangePassword] Updating password...');
      await user.updatePassword(newPassword);
      dev.log('✅ [ChangePassword] Password updated');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        dev.log('❌ [ChangePassword] Wrong current password');
        throw 'বর্তমান পাসওয়ার্ড ভুল';
      }
      dev.log('❌ [ChangePassword] Error: ${e.code}');
      throw 'পাসওয়ার্ড পরিবর্তন করতে সমস্যা হয়েছে';
    } catch (e) {
      dev.log('❌ [ChangePassword] Error: $e');
      throw 'পাসওয়ার্ড পরিবর্তন করতে সমস্যা হয়েছে';
    }
  }
}
