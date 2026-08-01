import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/data/models/micro_job_model.dart';
import 'package:global_earn/features/home/data/models/submission_model.dart';
import 'package:global_earn/features/home/presentation/bloc/job_approval_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/job_approval_event.dart';
import 'package:global_earn/features/home/presentation/bloc/job_approval_state.dart';
import 'package:global_earn/features/home/presentation/widgets/job_approval/my_jobs_tab_bar.dart';
import 'package:global_earn/features/home/presentation/widgets/job_approval/submission_card.dart';
import 'package:global_earn/features/home/presentation/widgets/job_approval/submission_filter_tabs.dart';
import 'package:global_earn/service_locator.dart';

class JobApprovalScreen extends StatefulWidget {
  const JobApprovalScreen({super.key});

  @override
  State<JobApprovalScreen> createState() => _JobApprovalScreenState();
}

class _JobApprovalScreenState extends State<JobApprovalScreen> {
  MicroJobModel? _selectedJob;
  String _filter = 'all';
  List<SubmissionModel> _allSubs = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobApprovalBloc>()..add(const LoadMyPostedJobs()),
      child: BlocConsumer<JobApprovalBloc, JobApprovalState>(
        listener: _onStateChange,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              elevation: 0,
              title: const Text(
                'জব অনুমোদন',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
                onPressed: () => context.pop(),
              ),
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, JobApprovalState state) {
    if (state is JobApprovalLoading &&
        _selectedJob == null &&
        _allSubs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is JobApprovalError && _selectedJob == null) {
      return _ErrorView(
        message: state.message,
        onRetry: () =>
            context.read<JobApprovalBloc>().add(const LoadMyPostedJobs()),
      );
    }

    final jobs = state is JobsLoaded ? state.jobs : <MicroJobModel>[];
    final filtered = _filter == 'all'
        ? _allSubs
        : _allSubs.where((s) => s.status == _filter).toList();

    return Column(
      children: [
        const SizedBox(height: 14),
        MyJobsTabBar(
          jobs: jobs,
          selectedJobId: _selectedJob?.id,
          onJobSelected: (job) {
            setState(() {
              _selectedJob = job;
              _filter = 'all';
              _allSubs = [];
            });
            context.read<JobApprovalBloc>().add(LoadSubmissions(job.id));
          },
        ),
        if (_selectedJob != null) ...[
          const SizedBox(height: 12),
          SubmissionFilterTabs(
            selectedFilter: _filter,
            allSubmissions: _allSubs,
            onFilterChanged: (f) => setState(() => _filter = f),
          ),
        ],
        Expanded(child: _buildSubmissionsArea(context, state, filtered)),
      ],
    );
  }

  Widget _buildSubmissionsArea(
    BuildContext ctx,
    JobApprovalState state,
    List<SubmissionModel> items,
  ) {
    if (_selectedJob == null) {
      return const Center(
        child: Text(
          'উপরে একটি জব বেছে নিন',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      );
    }
    if (state is JobApprovalLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state is JobApprovalError) {
      return _ErrorView(
        message: state.message,
        onRetry: () =>
            ctx.read<JobApprovalBloc>().add(LoadSubmissions(_selectedJob!.id)),
      );
    }
    if (items.isEmpty) {
      return const _EmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => SubmissionCard(submission: items[i]),
    );
  }

  void _onStateChange(BuildContext context, JobApprovalState state) {
    if (state is SubmissionsLoaded) {
      setState(() => _allSubs = state.submissions);
    }
    if (state is ApprovalSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সাবমিশন অনুমোদিত হয়েছে'),
          backgroundColor: AppColors.success,
        ),
      );
      context.read<JobApprovalBloc>().add(LoadSubmissions(state.jobId));
    }
    if (state is RejectionSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সাবমিশন প্রত্যাখ্যান করা হয়েছে'),
          backgroundColor: AppColors.error,
        ),
      );
      context.read<JobApprovalBloc>().add(LoadSubmissions(state.jobId));
    }
    if (state is JobApprovalError && _selectedJob != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'কোনো সাবমিশন পাওয়া যায়নি',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
