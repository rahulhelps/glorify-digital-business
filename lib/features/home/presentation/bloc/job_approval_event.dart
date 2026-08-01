import 'package:equatable/equatable.dart';
import 'package:global_earn/features/home/data/models/submission_model.dart';

abstract class JobApprovalEvent extends Equatable {
  const JobApprovalEvent();
  @override
  List<Object?> get props => [];
}

/// Load all jobs posted by the current user.
class LoadMyPostedJobs extends JobApprovalEvent {
  const LoadMyPostedJobs();
}

/// Load submissions for a selected job.
class LoadSubmissions extends JobApprovalEvent {
  final String jobId;
  const LoadSubmissions(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

/// Approve a single submission.
class ApproveSubmission extends JobApprovalEvent {
  final SubmissionModel submission;
  const ApproveSubmission(this.submission);
  @override
  List<Object?> get props => [submission.submissionId];
}

/// Reject a single submission.
class RejectSubmission extends JobApprovalEvent {
  final SubmissionModel submission;
  const RejectSubmission(this.submission);
  @override
  List<Object?> get props => [submission.submissionId];
}
