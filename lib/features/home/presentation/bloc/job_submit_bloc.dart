import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/home/domain/repositories/job_submit_repository.dart';
import 'job_submit_event.dart';
import 'job_submit_state.dart';

class JobSubmitBloc extends Bloc<JobSubmitEvent, JobSubmitState> {
  final JobSubmitRepository _repository;
  final FirebaseAuth _auth;
  final NetworkInfo _networkInfo;

  JobSubmitBloc({
    required JobSubmitRepository repository,
    required FirebaseAuth auth,
    required NetworkInfo networkInfo,
  }) : _repository = repository,
       _auth = auth,
       _networkInfo = networkInfo,
       super(const JobSubmitInitial()) {
    on<LoadJobDetail>(_onLoadJobDetail);
    on<ProofImagePicked>(_onProofImagePicked);
    on<ProofImageRemoved>(_onProofImageRemoved);
    on<SubmitJob>(_onSubmitJob);
  }

  // ── Load job detail ─────────────────────────────────────────────────────────
  Future<void> _onLoadJobDetail(
    LoadJobDetail event,
    Emitter<JobSubmitState> emit,
  ) async {
    debugPrint('🔥 [JobSubmit] Loading job: ${event.jobId}');
    emit(const JobSubmitLoading());
    try {
      final job = await _repository.getJobById(event.jobId);
      emit(JobDetailLoaded(job: job, proofImages: List.filled(3, null)));
    } catch (e) {
      debugPrint('❌ [JobSubmit] Error: $e');
      emit(JobSubmitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ── Image picked ────────────────────────────────────────────────────────────
  void _onProofImagePicked(
    ProofImagePicked event,
    Emitter<JobSubmitState> emit,
  ) {
    if (state is JobDetailLoaded) {
      final currentState = state as JobDetailLoaded;
      final updatedImages = List<File?>.from(currentState.proofImages);
      updatedImages[event.index] = event.image;
      emit(currentState.copyWith(proofImages: updatedImages));
    }
  }

  void _onProofImageRemoved(
    ProofImageRemoved event,
    Emitter<JobSubmitState> emit,
  ) {
    if (state is JobDetailLoaded) {
      final currentState = state as JobDetailLoaded;
      final updatedImages = List<File?>.from(currentState.proofImages);
      updatedImages[event.index] = null;
      emit(currentState.copyWith(proofImages: updatedImages));
    }
  }

  // ── Submit ───────────────────────────────────────────────────────────────────
  Future<void> _onSubmitJob(
    SubmitJob event,
    Emitter<JobSubmitState> emit,
  ) async {
    if (state is! JobDetailLoaded) return;
    final loaded = state as JobDetailLoaded;
    final job = loaded.job;

    try {
      // Check internet
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) throw NetworkException('ইন্টারনেট সংযোগ নেই');

      emit(const JobSubmitLoading());
      debugPrint('🔥 [JobSubmit] Checking guards...');

      final uid = _auth.currentUser?.uid;

      // Guard: own job
      if (uid == job.userId) {
        emit(JobSubmitError('আপনি নিজের জব সাবমিট করতে পারবেন না'));
        return;
      }

      // Guard: slots full
      if (job.completedCount >= job.totalJobLimit) {
        emit(const JobSlotsFull());
        return;
      }

      // Guard: already submitted
      final alreadyDone = await _repository.hasAlreadySubmitted(job.id);
      if (alreadyDone) {
        emit(const JobAlreadySubmitted());
        return;
      }

      debugPrint('✅ [JobSubmit] Guards passed');

      // Upload proof image (required)
      if (loaded.proofImages.isEmpty || loaded.proofImages[0] == null) {
        emit(loaded); // restore
        emit(const JobSubmitError('প্রমাণের প্রথম ছবিটি অবশ্যই নির্বাচন করতে হবে'));
        return;
      }

      debugPrint('🔥 [JobSubmit] Uploading proofs...');
      final validImages = loaded.proofImages.whereType<File>().toList();
      final uploadedUrls = await Future.wait(
        validImages.map((file) => _repository.uploadProofImage(file))
      );

      // Save to Firestore
      final submissionId = await _repository.submitJob(
        jobId: job.id,
        jobTitle: job.jobName,
        proofImageUrls: uploadedUrls,
        proofText: event.proofText,
        reward: job.perJobAmount,
      );

      debugPrint('✅ [JobSubmit] Submitted: $submissionId');
      emit(const JobSubmitSuccess());
    } catch (e) {
      debugPrint('❌ [JobSubmit] Error: $e');
      final msg = _toUserMessage(e);
      // Restore detail state so user can retry
      if (state is! JobDetailLoaded) {
        emit(loaded);
      }
      emit(JobSubmitError(msg));
    }
  }

  String _toUserMessage(Object e) {
    if (e is NetworkException) return e.message;
    final s = e.toString().replaceFirst('Exception: ', '');
    if (s.contains('ইন্টারনেট')) return 'ইন্টারনেট সংযোগ নেই';
    if (s.contains('আপলোড') || s.contains('ছবি আপলোড')) {
      return 'ছবি আপলোড করতে সমস্যা হয়েছে';
    }
    return s;
  }
}
