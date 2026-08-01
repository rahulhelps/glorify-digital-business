import 'dart:io';
import 'package:global_earn/features/tasks/data/models/ads_view_task_model.dart';

abstract class AdsViewRepository {
  /// Returns true if an image with this SHA-256 hash already exists in Firestore.
  Future<bool> isDuplicateHash(String hash);

  /// Uploads [imageFile] to Cloudinary and returns the secure URL.
  Future<String> uploadScreenshot(File imageFile);

  /// Creates a new document in ads_view_tasks and returns the created model.
  Future<AdsViewTaskModel> submitTask({
    required String userId,
    required String imageUrl,
    required String imageHash,
  });

  /// Streams all ads_view tasks for [userId].
  Stream<List<AdsViewTaskModel>> watchUserTasks(String userId);

  /// Fetches the dynamic Telegram bot URL from app_config/ads_view_config.
  Future<String> getTelegramBotUrl();
}
