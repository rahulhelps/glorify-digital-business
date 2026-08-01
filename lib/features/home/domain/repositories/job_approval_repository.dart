import 'package:global_earn/features/home/data/models/micro_job_model.dart';
import 'package:global_earn/features/home/data/models/submission_model.dart';

abstract class JobApprovalRepository {
  /// Fetch all jobs posted by the currently logged-in user.
  Future<List<MicroJobModel>> getMyPostedJobs();

  /// Fetch all submissions for a given [jobId].
  Future<List<SubmissionModel>> getSubmissionsForJob(String jobId);

  /// Approve a submission: atomic batch that updates submission status,
  /// increments filledSlots, credits submitter's balance, and writes
  /// an income_history record.
  Future<void> approveSubmission(SubmissionModel submission);

  /// Reject a submission: update submission status to 'rejected' and restore slot.
  Future<void> rejectSubmission(SubmissionModel submission);
}
