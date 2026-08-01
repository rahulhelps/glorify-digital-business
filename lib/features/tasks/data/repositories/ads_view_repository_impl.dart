import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:global_earn/core/services/cloudinary_config_service.dart';
import 'package:global_earn/features/tasks/data/models/ads_view_task_model.dart';
import 'package:global_earn/features/tasks/domain/repositories/ads_view_repository.dart';

class AdsViewRepositoryImpl implements AdsViewRepository {
  final FirebaseFirestore _firestore;

  // ── Firestore collection ───────────────────────────────────────────────────
  static const _collection = 'ads_view_tasks';

  AdsViewRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // ── Duplicate hash check ───────────────────────────────────────────────────
  @override
  Future<bool> isDuplicateHash(String hash) async {
    dev.log('🔍 [AdsView] Checking duplicate hash: $hash', name: 'AdsView');
    final query = await _firestore
        .collection(_collection)
        .where('imageHash', isEqualTo: hash)
        .limit(1)
        .get();
    final isDuplicate = query.docs.isNotEmpty;
    dev.log(
      isDuplicate ? '⚠️ [AdsView] Duplicate found!' : '✅ [AdsView] Hash is unique',
      name: 'AdsView',
    );
    return isDuplicate;
  }

  // ── Cloudinary upload ──────────────────────────────────────────────────────
  @override
  Future<String> uploadScreenshot(File imageFile) async {
    dev.log('☁️ [AdsView] Uploading screenshot to Cloudinary...', name: 'AdsView');
    final uri = Uri.parse(CloudinaryConfigService.uploadUrl);
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfigService.uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final url = data['secure_url'] as String;
      dev.log('✅ [AdsView] Upload complete: $url', name: 'AdsView');
      return url;
    } else {
      dev.log(
        '❌ [AdsView] Cloudinary error ${response.statusCode}: ${response.body}',
        name: 'AdsView',
      );
      throw 'স্ক্রিনশট আপলোড ব্যর্থ হয়েছে (HTTP ${response.statusCode})';
    }
  }

  // ── Firestore document creation ────────────────────────────────────────────
  @override
  Future<AdsViewTaskModel> submitTask({
    required String userId,
    required String imageUrl,
    required String imageHash,
  }) async {
    dev.log('📝 [AdsView] Creating task document...', name: 'AdsView');
    final ref = _firestore.collection(_collection).doc();
    final model = AdsViewTaskModel(
      taskId: ref.id,
      userId: userId,
      imageUrl: imageUrl,
      imageHash: imageHash,
      status: 'pending',
      amount: 0.0,
      submittedAt: DateTime.now(),
    );

    await ref.set(model.toJson());
    dev.log('✅ [AdsView] Task submitted: ${ref.id}', name: 'AdsView');
    return model;
  }

  // ── Real-time task stream ──────────────────────────────────────────────────
  @override
  Stream<List<AdsViewTaskModel>> watchUserTasks(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => AdsViewTaskModel.fromJson(d.data(), d.id))
              .toList(),
        );
  }

  // ── Dynamic Telegram URL ───────────────────────────────────────────────────
  @override
  Future<String> getTelegramBotUrl() async {
    dev.log('🔗 [AdsView] Fetching Telegram bot URL...', name: 'AdsView');
    try {
      final doc =
          await _firestore.doc('app_config/general_settings').get();
      if (doc.exists && doc.data() != null) {
        final url = doc.data()!['telegram_bot_url'] as String? ?? '';
        if (url.isNotEmpty) return url;
      }
    } catch (e) {
      dev.log('⚠️ [AdsView] Could not fetch config: $e', name: 'AdsView');
    }
    // Fallback — replace with real bot link
    return 'https://t.me/LifeChangeBotAds';
  }
}
