import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/presentation/bloc/submission_history_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/submission_history_event.dart';
import 'package:global_earn/features/home/presentation/bloc/submission_history_state.dart';
import 'package:global_earn/features/home/presentation/widgets/submission_history/submission_history_card.dart';

class SubmissionHistoryScreen extends StatefulWidget {
  const SubmissionHistoryScreen({super.key});

  @override
  State<SubmissionHistoryScreen> createState() =>
      _SubmissionHistoryScreenState();
}

class _SubmissionHistoryScreenState extends State<SubmissionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SubmissionHistoryBloc>().add(LoadSubmissionHistory());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'সাবমিশন হিস্ট্রি',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<SubmissionHistoryBloc, SubmissionHistoryState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is SubmissionHistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is SubmissionHistoryError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SubmissionHistoryBloc>().add(
                      LoadSubmissionHistory(),
                    ),
                    child: const Text('আবার চেষ্টা করুন'),
                  ),
                ],
              ),
            );
          }

          if (state is SubmissionHistoryLoaded) {
            final submissions = state.submissions;

            if (submissions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_edu_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'কোনো সাবমিশন পাওয়া যায়নি',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                return SubmissionHistoryCard(submission: submissions[index]);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
