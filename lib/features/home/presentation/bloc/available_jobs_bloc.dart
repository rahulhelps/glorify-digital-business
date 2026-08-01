import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/network/network_info.dart';
import '../../data/models/micro_job_model.dart';
import '../../domain/repositories/home_repository.dart';
import 'available_jobs_event.dart';
import 'available_jobs_state.dart';

class AvailableJobsBloc extends Bloc<AvailableJobsEvent, AvailableJobsState> {
  final HomeRepository _homeRepository;
  final NetworkInfo _networkInfo;
  StreamSubscription? _jobsSubscription;

  AvailableJobsBloc({
    required HomeRepository homeRepository,
    required NetworkInfo networkInfo,
  }) : _homeRepository = homeRepository,
       _networkInfo = networkInfo,
       super(AvailableJobsInitial()) {
    on<FetchAvailableJobs>(_onFetch);
    on<_JobsUpdated>(_onJobsUpdated);
    on<_JobsErrored>(_onJobsErrored);
  }

  Future<void> _onFetch(
    FetchAvailableJobs event,
    Emitter<AvailableJobsState> emit,
  ) async {
    emit(AvailableJobsLoading());

    // ── Check internet ──────────────────────────────────────────────────────
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      debugPrint('❌ [AvailableJobs] No internet');
      emit(const AvailableJobsFailure('ইন্টারনেট সংযোগ নেই'));
      return;
    }

    // ── Cancel existing subscription if any ────────────────────────────────
    await _jobsSubscription?.cancel();

    // ── Start real-time stream ──────────────────────────────────────────────
    try {
      _jobsSubscription = _homeRepository.watchAvailableJobs().listen(
        (jobs) => add(_JobsUpdated(jobs)),
        onError: (e) {
          debugPrint('❌ [AvailableJobs] Error: $e');
          add(_JobsErrored('জব লোড করতে সমস্যা হয়েছে'));
        },
      );
    } catch (e) {
      debugPrint('❌ [AvailableJobs] Error: $e');
      emit(const AvailableJobsFailure('জব লোড করতে সমস্যা হয়েছে'));
    }
  }

  void _onJobsUpdated(_JobsUpdated event, Emitter<AvailableJobsState> emit) {
    debugPrint('✅ [AvailableJobs] Found ${event.jobs.length} jobs');
    emit(AvailableJobsLoaded(event.jobs));
  }

  void _onJobsErrored(_JobsErrored event, Emitter<AvailableJobsState> emit) {
    emit(AvailableJobsFailure(event.message));
  }

  @override
  Future<void> close() async {
    await _jobsSubscription?.cancel();
    return super.close();
  }
}

// ── Internal events (not exposed to UI) ──────────────────────────────────────
class _JobsUpdated extends AvailableJobsEvent {
  final List<MicroJobModel> jobs;
  const _JobsUpdated(this.jobs);
}

class _JobsErrored extends AvailableJobsEvent {
  final String message;
  const _JobsErrored(this.message);
}
