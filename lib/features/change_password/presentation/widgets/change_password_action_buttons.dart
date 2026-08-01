import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/change_password/presentation/bloc/change_password_bloc.dart';
import 'package:global_earn/features/change_password/presentation/bloc/change_password_event.dart';
import 'package:global_earn/features/change_password/presentation/bloc/change_password_state.dart';

class ChangePasswordActionButtons extends StatelessWidget {
  final TextEditingController currentController;
  final TextEditingController newController;

  const ChangePasswordActionButtons({
    super.key,
    required this.currentController,
    required this.newController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        final bool isEnabled = state is ChangePasswordValid && state.canSubmit;

        return Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                gradient: isEnabled
                    ? const LinearGradient(
                        colors: [AppColors.primary, Color(0xFFff9f7d)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isEnabled ? null : Colors.grey.shade300,
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  onTap: isEnabled
                      ? () {
                          context.read<ChangePasswordBloc>().add(
                            SubmitChangePassword(
                              current: currentController.text,
                              newPass: newController.text,
                            ),
                          );
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: state is ChangePasswordLoading
                          ? [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ]
                          : [
                              Text(
                                '?????????? ???????? ????',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isEnabled
                                      ? AppColors.white
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: AppSizes.spacingXs),
                              Icon(
                                Icons.sync_alt,
                                color: isEnabled
                                    ? AppColors.white
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                            ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: Text(
                '????? ????',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

