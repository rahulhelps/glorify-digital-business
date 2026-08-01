import 'package:equatable/equatable.dart';
import 'package:global_earn/features/home/data/models/submission_model.dart';

abstract class SubmissionHistoryState extends Equatable {
  const SubmissionHistoryState();
  @override
  List<Object?> get props => [];
}

class SubmissionHistoryInitial extends SubmissionHistoryState {}

class SubmissionHistoryLoading extends SubmissionHistoryState {}

class SubmissionHistoryLoaded extends SubmissionHistoryState {
  final List<SubmissionModel> submissions;
  const SubmissionHistoryLoaded(this.submissions);
  @override
  List<Object?> get props => [submissions];
}

class SubmissionHistoryError extends SubmissionHistoryState {
  final String message;
  const SubmissionHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
