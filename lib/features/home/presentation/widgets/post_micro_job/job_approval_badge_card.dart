import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';

class JobApprovalBadgeCard extends StatefulWidget {
  const JobApprovalBadgeCard({super.key});

  @override
  State<JobApprovalBadgeCard> createState() => _JobApprovalBadgeCardState();
}

class _JobApprovalBadgeCardState extends State<JobApprovalBadgeCard> {
  int _pendingCount = 0;
  StreamSubscription? _jobsSub;
  final List<StreamSubscription> _submissionsSubs = [];
  final Map<String, int> _countsPerChunk = {};

  @override
  void initState() {
    super.initState();
    _listenToPendingCount();
  }

  void _listenToPendingCount() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _jobsSub = FirebaseFirestore.instance
        .collection('job_posts')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((jobSnap) {
      _processJobs(jobSnap.docs.map((d) => d.id).toList());
    });
  }

  void _processJobs(List<String> jobIds) {
    for (var sub in _submissionsSubs) {
      sub.cancel();
    }
    _submissionsSubs.clear();
    _countsPerChunk.clear();

    if (jobIds.isEmpty) {
      if (mounted) setState(() => _pendingCount = 0);
      return;
    }

    final chunks = <List<String>>[];
    for (var i = 0; i < jobIds.length; i += 10) {
      chunks.add(
        jobIds.sublist(i, i + 10 > jobIds.length ? jobIds.length : i + 10),
      );
    }

    for (int i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];
      final sub = FirebaseFirestore.instance
          .collection('job_submissions')
          .where('jobId', whereIn: chunk)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen((subSnap) {
        _countsPerChunk['chunk_$i'] = subSnap.docs.length;
        int total = 0;
        for (var count in _countsPerChunk.values) {
          total += count;
        }
        if (mounted) {
          setState(() {
            _pendingCount = total;
          });
        }
      });
      _submissionsSubs.add(sub);
    }
  }

  @override
  void dispose() {
    _jobsSub?.cancel();
    for (var sub in _submissionsSubs) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/home/job-approval'),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00BFA5), Color(0xFF00E676)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.history_outlined, color: Color(0xFF00BFA5)),
                      SizedBox(width: 8),
                      Text(
                        'জব পোস্ট হিস্টোরি ও অনুমোদন',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_pendingCount > 0)
                  Positioned(
                    top: 10,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BFA5), Color(0xFF00E676)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E676).withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$_pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
