import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:global_earn/core/services/cloudinary_config_service.dart';
import 'package:global_earn/core/network/network_info.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/micro_job_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NetworkInfo _networkInfo;

  HomeRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required NetworkInfo networkInfo,
  }) : _firestore = firestore,
       _auth = auth,
       _networkInfo = networkInfo;

  // ── Post job ───────────────────────────────────────────────────────────────
  @override
  Future<void> postMicroJob(MicroJobModel job) async {
    final batch = _firestore.batch();
    final jobRef = _firestore.collection('job_posts').doc(job.id);
    final userRef = _firestore.collection('users').doc(job.userId);

    final totalCost = job.perJobAmount * job.totalJobLimit;

    // 1. Save job
    batch.set(jobRef, job.toMap());

    // 2. Deduct from user balance
    batch.update(userRef, {
      'balance.earning': FieldValue.increment(-totalCost),
      'balance.total': FieldValue.increment(-totalCost),
    });

    // 3. Add history record (using voucher_history or creating spend_history)
    // For now, let's just commit the balance deduction
    await batch.commit();
  }

  // ── Cloudinary image upload ────────────────────────────────────────────────
  @override
  Future<String> uploadJobImage(File imageFile, String uid) async {
    debugPrint('🔥 [Cloudinary] Starting upload...');
    debugPrint('🔥 [Cloudinary] File size: ${imageFile.lengthSync()} bytes');

    if (!await imageFile.exists()) {
      throw Exception('ছবি খুঁজে পাওয়া যায়নি');
    }

    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      throw NetworkException('ইন্টারনেট সংযোগ নেই');
    }

    try {
      final uri = Uri.parse(CloudinaryConfigService.uploadUrl);
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = CloudinaryConfigService.uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final body = await streamedResponse.stream.bytesToString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (streamedResponse.statusCode == 200) {
        final url = json['secure_url'] as String;
        debugPrint('✅ [Cloudinary] Upload success: $url');
        return url;
      } else {
        final errorMsg = json['error']?['message'] ?? 'Unknown error';
        debugPrint('❌ [Cloudinary] Upload failed: $errorMsg');
        throw Exception('ছবি আপলোড করতে সমস্যা হয়েছে');
      }
    } catch (e) {
      debugPrint('❌ [Cloudinary] Upload failed: $e');
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('ছবি আপলোড করতে সমস্যা হয়েছে');
    }
  }

  // ── User balance ───────────────────────────────────────────────────────────
  @override
  Future<double> getUserBalance() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 0.0;

    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return 0.0;

    final balanceData = doc.data()?['balance'];
    if (balanceData != null && balanceData is Map) {
      return (balanceData['earning'] ?? 0.0).toDouble();
    }
    return 0.0;
  }

  // ── One-time fetch (kept for compatibility) ────────────────────────────────
  @override
  Future<List<MicroJobModel>> getAvailableJobs() async {
    debugPrint('🔥 [AvailableJobs] Fetching jobs...');
    try {
      final snapshot = await _firestore
          .collection('job_posts')
          .where('status', isEqualTo: 'active') // Only show active jobs
          .orderBy('createdAt', descending: true)
          .get();

      final jobs = snapshot.docs
          .map((doc) => MicroJobModel.fromMap(doc.data(), docId: doc.id))
          .toList();

      debugPrint('✅ [AvailableJobs] Found ${jobs.length} jobs');
      return jobs;
    } catch (e) {
      debugPrint('❌ [AvailableJobs] Error: $e');
      rethrow;
    }
  }

  // ── Real-time stream ───────────────────────────────────────────────────────
  @override
  Stream<List<MicroJobModel>> watchAvailableJobs() {
    debugPrint('🔥 [AvailableJobs] Starting real-time stream...');
    return _firestore
        .collection('job_posts')
        .where('status', isEqualTo: 'active') // Only show active jobs
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          debugPrint('✅ [AvailableJobs] Found ${snapshot.docs.length} jobs');
          return snapshot.docs
              .map((doc) => MicroJobModel.fromMap(doc.data(), docId: doc.id))
              .toList();
        });
  }
}
