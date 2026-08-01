import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/home/domain/repositories/job_submit_repository.dart';
import 'submission_history_event.dart';
import 'submission_history_state.dart';

class SubmissionHistoryBloc
    extends Bloc<SubmissionHistoryEvent, SubmissionHistoryState> {
  final JobSubmitRepository _repository;
  StreamSubscription? _subscription;

  SubmissionHistoryBloc({required JobSubmitRepository repository})
    : _repository = repository,
      super(SubmissionHistoryInitial()) {
    on<LoadSubmissionHistory>(_onLoadHistory);
    on<SubmissionHistoryUpdated>(
      (event, emit) => emit(SubmissionHistoryLoaded(event.submissions)),
    );
  }

  Future<void> _onLoadHistory(
    LoadSubmissionHistory event,
    Emitter<SubmissionHistoryState> emit,
  ) async {
    emit(SubmissionHistoryLoading());
    await _subscription?.cancel();

    _subscription = _repository.watchSubmissionHistory().listen(
      (submissions) => add(SubmissionHistoryUpdated(submissions)),
      onError: (error) => emit(SubmissionHistoryError(error.toString())),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
