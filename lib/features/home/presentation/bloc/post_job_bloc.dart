import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:global_earn/core/services/cloudinary_config_service.dart';
import 'package:global_earn/core/network/network_info.dart';
import '../../data/models/micro_job_model.dart';
import '../../domain/repositories/home_repository.dart';
import 'post_job_event.dart';
import 'post_job_state.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';

class PostJobBloc extends Bloc<PostJobEvent, PostJobState> {
  final HomeRepository _homeRepository;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final NetworkInfo _networkInfo;
  final UserBloc _userBloc;

  PostJobBloc({
    required HomeRepository homeRepository,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required NetworkInfo networkInfo,
    required UserBloc userBloc,
  }) : _homeRepository = homeRepository,
       _auth = auth,
       _firestore = firestore,
       _networkInfo = networkInfo,
       _userBloc = userBloc,
       super(const PostJobInitial()) {
    on<PostJobFormChanged>(_onFormChanged);
    on<PostJobImagePicked>(_onImagePicked);
    on<PostJobSubmitted>(_onSubmitted);
  }

  void _onFormChanged(PostJobFormChanged event, Emitter<PostJobState> emit) {
    emit(
      PostJobFormUpdated(
        jobName: event.jobName ?? state.jobName,
        jobDescription: event.jobDescription ?? state.jobDescription,
        jobLink: event.jobLink ?? state.jobLink,
        perJobAmount: event.perJobAmount ?? state.perJobAmount,
        totalJobLimit: event.totalJobLimit ?? state.totalJobLimit,
        image: state.image,
      ),
    );
  }

  void _onImagePicked(PostJobImagePicked event, Emitter<PostJobState> emit) {
    emit(
      PostJobFormUpdated(
        jobName: state.jobName,
        jobDescription: state.jobDescription,
        jobLink: state.jobLink,
        perJobAmount: state.perJobAmount,
        totalJobLimit: state.totalJobLimit,
        image: event.image,
      ),
    );
  }

  Future<void> _onSubmitted(
    PostJobSubmitted event,
    Emitter<PostJobState> emit,
  ) async {
    if (!state.isFormValid) return;

    try {
      // ── Step 1: Check internet ───────────────────────────────────────────
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw NetworkException('ইন্টারনেট সংযোগ নেই');
      }

      // ── Step 2: Check image file ─────────────────────────────────────────
      if (state.image == null || !await state.image!.exists()) {
        throw Exception('ছবি খুঁজে পাওয়া যায়নি');
      }

      emit(_loadingState(0.1));

      final user = _auth.currentUser;
      if (user == null) throw Exception('ব্যবহারকারী লগইন করা নেই');

      // ── Step 3: Check Balance ────────────────────────────────────────────
      final userState = _userBloc.state;
      if (userState is! UserLoaded) {
        throw Exception('ব্যবহারকারীর তথ্য পাওয়া যায়নি');
      }

      final reward = double.parse(state.perJobAmount);
      final totalSlots = int.parse(state.totalJobLimit);
      final requiredAmount = reward * totalSlots;
      final userBalance = userState.user.withdrawableBalance;

      debugPrint(
        '🔥 [JobPost] Required: $requiredAmount, Available: $userBalance',
      );

      if (userBalance < requiredAmount) {
        debugPrint('❌ [JobPost] Insufficient balance');
        throw Exception(
          'অপর্যাপ্ত ব্যালেন্স। প্রয়োজন: ৳$requiredAmount, আপনার ব্যালেন্স: ৳$userBalance',
        );
      }
      debugPrint('✅ [JobPost] Balance check passed');

      // ── Step 4: Fetch user name ──────────────────────────────────────────
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] ?? 'Unknown User';

      // ── Step 5: Compress image ───────────────────────────────────────────
      emit(_loadingState(0.3));
      final compressedImage = await _compressImage(state.image!);
      if (compressedImage == null) {
        throw Exception('ছবি কম্প্রেস করতে সমস্যা হয়েছে');
      }

      // ── Step 6: Upload to Cloudinary ─────────────────────────────────────
      emit(_loadingState(0.6));
      debugPrint('🔥 [Cloudinary] Starting upload...');
      debugPrint(
        '🔥 [Cloudinary] File size: ${compressedImage.lengthSync()} bytes',
      );

      final imageUrl = await _uploadToCloudinary(compressedImage);

      // ── Step 7: Save job to Firestore ────────────────────────────────────
      emit(_loadingState(0.9));
      final jobId = DateTime.now().millisecondsSinceEpoch.toString();
      final job = MicroJobModel(
        id: jobId,
        userId: user.uid,
        posterName: userName,
        jobName: state.jobName,
        jobDescription: state.jobDescription,
        jobLink: state.jobLink,
        perJobAmount: double.parse(state.perJobAmount),
        totalJobLimit: int.parse(state.totalJobLimit),
        featureImage: imageUrl,
        status: 'pending', // Pending status logic implemented
        createdAt: DateTime.now(),
      );

      await _homeRepository.postMicroJob(job);
      emit(const PostJobSuccess());
    } catch (e) {
      debugPrint('❌ [Cloudinary] Upload failed: $e');
      final message = _toUserMessage(e);
      emit(
        PostJobFailure(
          message,
          jobName: state.jobName,
          jobDescription: state.jobDescription,
          jobLink: state.jobLink,
          perJobAmount: state.perJobAmount,
          totalJobLimit: state.totalJobLimit,
          image: state.image,
        ),
      );
    }
  }

  // ── Cloudinary upload ─────────────────────────────────────────────────────
  Future<String> _uploadToCloudinary(File imageFile) async {
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
    }
    throw Exception('ছবি আপলোড করতে সমস্যা হয়েছে');
  }

  // ── Image compression ─────────────────────────────────────────────────────
  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    return result != null ? File(result.path) : null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  PostJobLoading _loadingState(double progress) => PostJobLoading(
    jobName: state.jobName,
    jobDescription: state.jobDescription,
    jobLink: state.jobLink,
    perJobAmount: state.perJobAmount,
    totalJobLimit: state.totalJobLimit,
    image: state.image,
    uploadProgress: progress,
  );

  String _toUserMessage(Object e) {
    if (e is NetworkException) return e.message;
    final msg = e.toString();
    if (msg.contains('ইন্টারনেট')) return 'ইন্টারনেট সংযোগ নেই';
    if (msg.contains('ছবি খুঁজে')) return 'ছবি খুঁজে পাওয়া যায়নি';
    if (msg.contains('আপলোড')) return 'ছবি আপলোড করতে সমস্যা হয়েছে';
    if (msg.contains('অপর্যাপ্ত ব্যালেন্স')) return msg;
    return 'জব পোস্ট করতে সমস্যা হয়েছে: $msg';
  }
}
