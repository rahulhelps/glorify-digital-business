import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/core/services/cloudinary_config_service.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/profile/domain/repositories/profile_repository.dart';
import 'dart:developer' as dev;

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({required this.firestore, required this.networkInfo});

  @override
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
    String? bio,
    DateTime? dateOfBirth,
  }) async {
    if (!await networkInfo.isConnected) throw 'ইন্টারনেট সংযোগ নেই';

    try {
      dev.log('🔥 [Profile] Updating profile for uid: $uid');
      final Map<String, dynamic> data = {
        'name': name,
        'phone': phone,
      };
      if (bio != null) {
        data['bio'] = bio;
      }
      if (dateOfBirth != null) {
        data['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
      }
      await firestore.collection('users').doc(uid).update(data);
      dev.log('✅ [Profile] Profile updated successfully');
    } catch (e) {
      dev.log('❌ [Profile] Update failed: $e');
      throw 'আপডেট করতে সমস্যা হয়েছে';
    }
  }

  @override
  Future<String> uploadProfilePhoto({
    required String uid,
    required File imageFile,
  }) async {
    if (!await networkInfo.isConnected) throw 'ইন্টারনেট সংযোগ নেই';

    try {
      dev.log('🔥 [Profile] Uploading photo to Cloudinary...');
      final url = Uri.parse(CloudinaryConfigService.uploadUrl);
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = CloudinaryConfigService.uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageUrl = data['secure_url'] as String;

        await firestore.collection('users').doc(uid).update({
          'profileImageUrl': imageUrl,
        });

        dev.log('✅ [Profile] Photo updated: $imageUrl');
        return imageUrl;
      } else {
        throw 'Photo upload failed with status: ${response.statusCode}';
      }
    } catch (e) {
      dev.log('❌ [Profile] Photo upload error: $e');
      throw 'ফটো আপলোড করতে সমস্যা হয়েছে';
    }
  }

  @override
  Future<UserModel> getUser(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw 'ব্যবহারকারী পাওয়া যায়নি';
    return UserModel.fromJson(doc.data()!);
  }

  @override
  Future<void> markVerificationBannerShown(String uid) async {
    try {
      dev.log('🔥 [Profile] Marking verification banner shown for uid: $uid');
      await firestore.collection('users').doc(uid).update({
        'verificationBannerShown': true,
      });
      dev.log('✅ [Profile] Verification banner marked as shown');
    } catch (e) {
      dev.log('❌ [Profile] Failed to mark banner shown: $e');
    }
  }
}
