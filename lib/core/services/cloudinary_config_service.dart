import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CloudinaryConfigService {
  static String _cloudName = ''; 
  static String _uploadPreset = ''; 

  static String get cloudName => _cloudName;
  static String get uploadPreset => _uploadPreset;
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Call once at app startup, before runApp. Fails silently and keeps
  /// the hardcoded fallback values if Firestore is unreachable or the
  /// document doesn't exist.
  static Future<void> load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('cloudinary')
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _cloudName = (data['cloudName'] as String?)?.trim().isNotEmpty == true
              ? data['cloudName'] as String
              : _cloudName;
          _uploadPreset = (data['uploadPreset'] as String?)?.trim().isNotEmpty == true
              ? data['uploadPreset'] as String
              : _uploadPreset;
          debugPrint('✅ [Cloudinary] Config loaded from Firebase: $_cloudName, $_uploadPreset');
        }
      }
    } catch (e) {
      // Silently keep fallback values — never block app startup on this.
      debugPrint('CloudinaryConfigService.load() failed, using fallback: $e');
    }
  }
}
