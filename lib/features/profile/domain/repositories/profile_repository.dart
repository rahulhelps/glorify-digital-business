import 'dart:io';

abstract class ProfileRepository {
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
    String? bio,
    DateTime? dateOfBirth,
  });

  Future<String> uploadProfilePhoto({
    required String uid,
    required File imageFile,
  });

  Future<dynamic> getUser(String uid); // Returns UserModel

  Future<void> markVerificationBannerShown(String uid);
}
