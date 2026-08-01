import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:global_earn/features/home/data/models/micro_job_model.dart';
import 'package:global_earn/features/home/data/models/submission_model.dart';
import 'package:global_earn/features/home/domain/repositories/job_approval_repository.dart';

class JobApprovalRepositoryImpl implements JobApprovalRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  JobApprovalRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  // ── My posted jobs ──────────────────────────────────────────────────────────
  @override
  Future<List<MicroJobModel>> getMyPostedJobs() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('ব্যবহারকারী লগইন করা নেই');

    debugPrint('🔥 [JobApproval] Querying jobs for uid: $uid');

    // Query by 'userId' — no orderBy to avoid composite-index requirement;
    // sort locally instead.
    final snap = await _firestore
        .collection('job_posts')
        .where('userId', isEqualTo: uid)
        .get();

    var jobs =
        snap.docs
            .map((d) => MicroJobModel.fromMap(d.data(), docId: d.id))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Fall-back: also try 'postedBy' field if nothing returned
    if (jobs.isEmpty) {
      debugPrint('🔥 [JobApproval] userId query empty, trying postedBy...');
      final snap2 = await _firestore
          .collection('job_posts')
          .where('postedBy', isEqualTo: uid)
          .get();
      jobs =
          snap2.docs
              .map((d) => MicroJobModel.fromMap(d.data(), docId: d.id))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint('✅ [JobApproval] Found ${jobs.length} jobs (postedBy)');
      return jobs;
    }

    debugPrint('✅ [JobApproval] Found ${jobs.length} jobs');
    return jobs;
  }

  // ── Submissions for a job ───────────────────────────────────────────────────
  @override
  Future<List<SubmissionModel>> getSubmissionsForJob(String jobId) async {
    debugPrint('🔥 [JobApproval] Loading submissions for job: $jobId');
    // No orderBy — avoids composite-index requirement; sort locally.
    final snap = await _firestore
        .collection('job_submissions')
        .where('jobId', isEqualTo: jobId)
        .get();
    final subs =
        snap.docs
            .map((d) => SubmissionModel.fromMap(d.data(), docId: d.id))
            .toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return subs;
  }

  // ── Approve ─────────────────────────────────────────────────────────────────
  @override
  Future<void> approveSubmission(SubmissionModel submission) async {
    debugPrint(
      '🔥 [JobApproval] Approving submission: ${submission.submissionId}',
    );

    final submitterUid = submission.submittedBy;
    final reward = submission.reward;
    final jobId = submission.jobId;
    final jobTitle = submission.jobTitle;

    final batch = _firestore.batch();

    // 1. Update submission status → approved
    final subRef = _firestore
        .collection('job_submissions')
        .doc(submission.submissionId);
    batch.update(subRef, {
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });

    // 2. Increment filledSlots on the job (completedCount was incremented on submission)
    final jobRef = _firestore.collection('job_posts').doc(jobId);
    batch.update(jobRef, {
      'filledSlots': FieldValue.increment(1),
    });

    // 3. Credit submitter's balance
    //    balance.total += reward  (total tracks earning + referral + voucher - withdrawn
    //    as a running sum; incrementing here keeps it in sync without a read)
    final userRef = _firestore.collection('users').doc(submitterUid);
    batch.update(userRef, {
      'balance.earning': FieldValue.increment(reward),
      'balance.total': FieldValue.increment(reward),
    });

    // 4. Write income_history record
    final incomeRef = _firestore.collection('income_history').doc();
    batch.set(incomeRef, {
      'uid': submitterUid,
      'amount': reward,
      'type': 'micro_job',
      'jobId': jobId,
      'jobTitle': jobTitle,
      'description': 'মাইক্রো জব সম্পন্ন: $jobTitle',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // ── Per-step confirmation logs ───────────────────────────────────────────
    debugPrint('✅ [Approval] filledSlots updated for job: $jobId');
    debugPrint('✅ [Approval] earning += $reward for user: $submitterUid');
    debugPrint('✅ [Approval] total balance updated');
    debugPrint('✅ [Approval] income_history record created');
    debugPrint('✅ [JobApproval] Approved — balance updated for $submitterUid');
  }

  // ── Reject ───────────────────────────────────────────────────────────────────
  @override
  Future<void> rejectSubmission(SubmissionModel submission) async {
    debugPrint('🔥 [JobApproval] Rejecting submission: ${submission.submissionId}');
    
    final batch = _firestore.batch();
    
    // 1. Update status to rejected
    final subRef = _firestore.collection('job_submissions').doc(submission.submissionId);
    batch.update(subRef, {
      'status': 'rejected',
    });
    
    // 2. Restore the slot by decrementing completedCount
    final jobRef = _firestore.collection('job_posts').doc(submission.jobId);
    batch.update(jobRef, {
      'completedCount': FieldValue.increment(-1),
    });
    
    await batch.commit();
    debugPrint('✅ [JobApproval] Rejected and slot restored: ${submission.submissionId}');
  }
}
