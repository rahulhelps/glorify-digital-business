import 'dart:io';
import 'package:global_earn/features/home/data/models/micro_job_model.dart';

import '../../data/models/submission_model.dart';

abstract class JobSubmitRepository {
  /// Fetch a single job by [jobId] from Firestore.
  Future<MicroJobModel> getJobById(String jobId);

  /// Returns true if the current user already submitted [jobId].
  Future<bool> hasAlreadySubmitted(String jobId);

  /// Upload [proofImage] to Cloudinary and return the secure URL.
  Future<String> uploadProofImage(File proofImage);

  /// Save the submission document to `job_submissions/`.
  Future<String> submitJob({
    required String jobId,
    required String jobTitle,
    required List<String> proofImageUrls,
    required String proofText,
    required double reward,
  });

  /// Real-time stream of submissions for the current user.
  Stream<List<SubmissionModel>> watchSubmissionHistory();
}
