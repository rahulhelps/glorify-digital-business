import 'package:equatable/equatable.dart';
import 'package:global_earn/features/home/data/models/micro_job_model.dart';
import 'package:global_earn/features/home/data/models/submission_model.dart';

abstract class JobApprovalState extends Equatable {
  const JobApprovalState();
  @override
  List<Object?> get props => [];
}

class JobApprovalInitial extends JobApprovalState {
  const JobApprovalInitial();
}

class JobApprovalLoading extends JobApprovalState {
  const JobApprovalLoading();
}

class JobsLoaded extends JobApprovalState {
  final List<MicroJobModel> jobs;
  const JobsLoaded(this.jobs);
  @override
  List<Object?> get props => [jobs];
}

class SubmissionsLoaded extends JobApprovalState {
  final List<SubmissionModel> submissions;
  final String jobId;
  const SubmissionsLoaded({required this.submissions, required this.jobId});
  @override
  List<Object?> get props => [submissions, jobId];
}

class ApprovalSuccess extends JobApprovalState {
  final String jobId;
  const ApprovalSuccess(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

class RejectionSuccess extends JobApprovalState {
  final String jobId;
  const RejectionSuccess(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

class JobApprovalError extends JobApprovalState {
  final String message;
  const JobApprovalError(this.message);
  @override
  List<Object?> get props => [message];
}
