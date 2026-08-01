import 'package:equatable/equatable.dart';
import 'package:global_earn/features/home/data/models/submission_model.dart';

abstract class SubmissionHistoryEvent extends Equatable {
  const SubmissionHistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadSubmissionHistory extends SubmissionHistoryEvent {}

class SubmissionHistoryUpdated extends SubmissionHistoryEvent {
  final List<SubmissionModel> submissions;
  const SubmissionHistoryUpdated(this.submissions);
  @override
  List<Object?> get props => [submissions];
}
