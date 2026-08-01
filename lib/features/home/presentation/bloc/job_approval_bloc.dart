import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/home/domain/repositories/job_approval_repository.dart';
import 'job_approval_event.dart';
import 'job_approval_state.dart';

class JobApprovalBloc extends Bloc<JobApprovalEvent, JobApprovalState> {
  final JobApprovalRepository _repository;
  final NetworkInfo _networkInfo;

  JobApprovalBloc({
    required JobApprovalRepository repository,
    required NetworkInfo networkInfo,
  }) : _repository = repository,
       _networkInfo = networkInfo,
       super(const JobApprovalInitial()) {
    on<LoadMyPostedJobs>(_onLoadMyJobs);
    on<LoadSubmissions>(_onLoadSubmissions);
    on<ApproveSubmission>(_onApprove);
    on<RejectSubmission>(_onReject);
  }

  // ── Load my posted jobs ─────────────────────────────────────────────────────
  Future<void> _onLoadMyJobs(
    LoadMyPostedJobs event,
    Emitter<JobApprovalState> emit,
  ) async {
    emit(const JobApprovalLoading());
    try {
      final jobs = await _repository.getMyPostedJobs();
      emit(JobsLoaded(jobs));
    } catch (e) {
      debugPrint('❌ [JobApproval] Error: $e');
      emit(JobApprovalError(_toUserMessage(e)));
    }
  }

  // ── Load submissions for a job ──────────────────────────────────────────────
  Future<void> _onLoadSubmissions(
    LoadSubmissions event,
    Emitter<JobApprovalState> emit,
  ) async {
    emit(const JobApprovalLoading());
    try {
      final subs = await _repository.getSubmissionsForJob(event.jobId);
      emit(SubmissionsLoaded(submissions: subs, jobId: event.jobId));
    } catch (e) {
      debugPrint('❌ [JobApproval] Error: $e');
      emit(JobApprovalError(_toUserMessage(e)));
    }
  }

  // ── Approve ─────────────────────────────────────────────────────────────────
  Future<void> _onApprove(
    ApproveSubmission event,
    Emitter<JobApprovalState> emit,
  ) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      emit(const JobApprovalError('ইন্টারনেট সংযোগ নেই'));
      return;
    }
    emit(const JobApprovalLoading());
    try {
      await _repository.approveSubmission(event.submission);
      emit(ApprovalSuccess(event.submission.jobId));
    } catch (e) {
      debugPrint('❌ [JobApproval] Error: $e');
      emit(
        const JobApprovalError('অনুমোদন করতে সমস্যা হয়েছে, আবার চেষ্টা করুন'),
      );
    }
  }

  // ── Reject ───────────────────────────────────────────────────────────────────
  Future<void> _onReject(
    RejectSubmission event,
    Emitter<JobApprovalState> emit,
  ) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      emit(const JobApprovalError('ইন্টারনেট সংযোগ নেই'));
      return;
    }
    emit(const JobApprovalLoading());
    try {
      await _repository.rejectSubmission(event.submission);
      emit(RejectionSuccess(event.submission.jobId));
    } catch (e) {
      debugPrint('❌ [JobApproval] Error: $e');
      emit(const JobApprovalError('প্রত্যাখ্যান করতে সমস্যা হয়েছে'));
    }
  }

  String _toUserMessage(Object e) {
    if (e is NetworkException) return e.message;
    final s = e.toString().replaceFirst('Exception: ', '');
    if (s.contains('ইন্টারনেট')) return 'ইন্টারনেট সংযোগ নেই';
    return s;
  }
}
