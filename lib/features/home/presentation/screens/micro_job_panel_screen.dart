import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/presentation/bloc/available_jobs_bloc.dart';
import 'package:global_earn/features/home/data/models/micro_job_model.dart';
import 'package:global_earn/features/home/presentation/bloc/available_jobs_event.dart';
import 'package:global_earn/features/home/presentation/bloc/available_jobs_state.dart';
import 'package:global_earn/features/home/presentation/widgets/micro_job_panel/job_grid.dart';
import 'package:global_earn/shared/widgets/verification_guard.dart';

class MicroJobPanelScreen extends StatefulWidget {
  const MicroJobPanelScreen({super.key});

  @override
  State<MicroJobPanelScreen> createState() => _MicroJobPanelScreenState();
}

class _MicroJobPanelScreenState extends State<MicroJobPanelScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AvailableJobsBloc>().add(FetchAvailableJobs());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VerificationGuard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        body: Column(
          children: [
            // ── Premium Dark Header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button Chip
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'ড্যাশবোর্ডে ফিরুন',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '📋 মাইক্রো জব (Micro Jobs)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'সহজ সহজ টাস্ক সম্পূর্ণ করে প্রতিদিন টাকা আয় করুন। সঠিক প্রুফ প্রদান করে দ্রুত পেমেন্ট বুঝে নিন।',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.push('/home/post-micro-job'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB300),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      '+ নিজের জব পোস্ট করুন',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // ── Tabs ───────────────────────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    children: [
                                      Icon(Icons.work_outline, color: AppColors.primary, size: 20),
                                      SizedBox(height: 6),
                                      Text(
                                        'একটিভ কাজের সুযোগ',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '(Available Jobs)',
                                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => context.push('/home/submission-history'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(Icons.history, color: AppColors.textSecondary, size: 20),
                                        SizedBox(height: 6),
                                        Text(
                                          'আমার কাজের হিস্ট্রি',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                        ),
                                        Text(
                                          '(Work History)',
                                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ── Search & Actions ──────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val.toLowerCase();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'মাইক্রো জব টাইটেল বা বিবরণ লিখে খুঁজুন...',
                                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FA),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => context.read<AvailableJobsBloc>().add(FetchAvailableJobs()),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F9FA),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => context.push('/home/post-micro-job'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFF9800),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: const Text(
                                          '+ জব পোস্ট করুন',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Job Grid ────────────────────────────────────────────────
                  BlocBuilder<AvailableJobsBloc, AvailableJobsState>(
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, state) {
                      if (state is AvailableJobsLoading) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        );
                      }

                      if (state is AvailableJobsFailure) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                                const SizedBox(height: 12),
                                Text(state.message),
                              ],
                            ),
                          ),
                        );
                      }

                      var jobs = state is AvailableJobsLoaded ? state.jobs : <MicroJobModel>[];

                      // Apply search filter locally
                      if (_searchQuery.isNotEmpty) {
                        jobs = jobs.where((job) {
                          return job.jobName.toLowerCase().contains(_searchQuery) ||
                                 job.jobDescription.toLowerCase().contains(_searchQuery);
                        }).toList();
                      }

                      if (jobs.isEmpty) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'কোনো জব পাওয়া যায়নি',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        sliver: JobGrid(jobs: jobs),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
