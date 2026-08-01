import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_event.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_state.dart';

class PostJobActions extends StatelessWidget {
  const PostJobActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostJobBloc, PostJobState>(
      listener: (context, state) {
        if (state is PostJobSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('জব সফলভাবে পোস্ট করা হয়েছে! 🎉'),
              backgroundColor: AppColors.secondary,
            ),
          );
          context.pop();
        }
        if (state is PostJobFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PostJobLoading;
        final isEnabled = state.isFormValid && !isLoading;

        return Column(
          children: [
            // ── Upload progress indicator ──────────────────────────────────
            if (isLoading && state.uploadProgress != null) ...[
              LinearProgressIndicator(
                value: state.uploadProgress,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),
              Text(
                'আপলোড হচ্ছে: ${(state.uploadProgress! * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Submit button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnabled
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: isEnabled ? 10 : 0,
                ),
                onPressed: isEnabled
                    ? () => context.read<PostJobBloc>().add(
                        const PostJobSubmitted(),
                      )
                    : null,
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Submit Business Request',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

          ],
        );
      },
    );
  }
}
