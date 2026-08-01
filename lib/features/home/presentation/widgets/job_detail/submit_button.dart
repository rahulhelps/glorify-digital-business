import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/presentation/bloc/job_submit_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/job_submit_event.dart';
import 'package:global_earn/features/home/presentation/bloc/job_submit_state.dart';

class SubmitButton extends StatelessWidget {
  final TextEditingController proofTextController;
  const SubmitButton({super.key, required this.proofTextController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobSubmitBloc, JobSubmitState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        final isLoading = state is JobSubmitLoading;
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: isLoading
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      context.read<JobSubmitBloc>().add(
                        SubmitJob(proofText: proofTextController.text.trim()),
                      );
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'সাবমিট করুন',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
