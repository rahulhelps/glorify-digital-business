import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:global_earn/core/services/cloudinary_config_service.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/home/data/models/micro_job_model.dart';
import 'package:global_earn/features/home/data/models/submission_model.dart';
import 'package:global_earn/features/home/domain/repositories/job_submit_repository.dart';

class JobSubmitRepositoryImpl implements JobSubmitRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NetworkInfo _networkInfo;

  JobSubmitRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required NetworkInfo networkInfo,
  }) : _firestore = firestore,
       _auth = auth,
       _networkInfo = networkInfo;

  // ── Fetch single job ────────────────────────────────────────────────────────
  @override
  Future<MicroJobModel> getJobById(String jobId) async {
    debugPrint('🔥 [JobSubmit] Loading job: $jobId');
    final doc = await _firestore.collection('job_posts').doc(jobId).get();
    if (!doc.exists) throw Exception('জব খুঁজে পাওয়া যায়নি');
    return MicroJobModel.fromMap(doc.data()!, docId: doc.id);
  }

  // ── Guard: already submitted? ───────────────────────────────────────────────
  @override
  Future<bool> hasAlreadySubmitted(String jobId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final snap = await _firestore
        .collection('job_submissions')
        .where('jobId', isEqualTo: jobId)
        .where('submittedBy', isEqualTo: uid)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  // ── Upload proof image to Cloudinary ────────────────────────────────────────
  @override
  Future<String> uploadProofImage(File proofImage) async {
    debugPrint('🔥 [JobSubmit] Uploading proof...');
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) throw NetworkException('ইন্টারনেট সংযোগ নেই');

    final uri = Uri.parse(CloudinaryConfigService.uploadUrl);
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfigService.uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', proofImage.path));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    final json = jsonDecode(body) as Map<String, dynamic>;

    if (streamed.statusCode == 200) {
      final url = json['secure_url'] as String;
      debugPrint('✅ [JobSubmit] Proof uploaded: $url');
      return url;
    }
    final msg = json['error']?['message'] ?? 'Unknown';
    debugPrint('❌ [JobSubmit] Upload failed: $msg');
    throw Exception('ছবি আপলোড করতে সমস্যা হয়েছে');
  }

  // ── Save submission to Firestore ────────────────────────────────────────────
  @override
  Future<String> submitJob({
    required String jobId,
    required String jobTitle,
    required List<String> proofImageUrls,
    required String proofText,
    required double reward,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ব্যবহারকারী লগইন করা নেই');

    // Fetch submitter's display name
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final submitterName = userDoc.data()?['name'] ?? 'Unknown';

    final ref = _firestore.collection('job_submissions').doc();
    final submissionId = ref.id;

    final batch = _firestore.batch();

    batch.set(ref, {
      'submissionId': submissionId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'submittedBy': user.uid,
      'submitterName': submitterName,
      'proofImages': proofImageUrls,
      'proofText': proofText,
      'status': 'pending',
      'reward': reward,
      'submittedAt': FieldValue.serverTimestamp(),
    });

    final jobRef = _firestore.collection('job_posts').doc(jobId);
    batch.update(jobRef, {
      'completedCount': FieldValue.increment(1),
    });

    await batch.commit();

    debugPrint('✅ [JobSubmit] Submitted: $submissionId');
    return submissionId;
  }

  @override
  Stream<List<SubmissionModel>> watchSubmissionHistory() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    debugPrint('🔥 [JobSubmit] Watching submission history for: $uid');

    // No orderBy in query to avoid index issues; sort locally
    return _firestore
        .collection('job_submissions')
        .where('submittedBy', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final docs = snap.docs
              .map((d) => SubmissionModel.fromMap(d.data(), docId: d.id))
              .toList();

          // Local sort: newest first
          docs.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

          return docs;
        });
  }
}
