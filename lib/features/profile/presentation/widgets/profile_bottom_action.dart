import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:global_earn/features/profile/presentation/bloc/profile_state.dart';

class ProfileBottomAction extends StatelessWidget {
  final VoidCallback onUpdate;

  const ProfileBottomAction({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        final isLoading = state is ProfileUpdating;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppSizes.marginMobile,
            AppSizes.spacingLg,
            AppSizes.marginMobile,
            AppSizes.spacingLg,
          ),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(color: AppColors.white.withValues(alpha: 0.05)),
            ),
          ),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                onTap: isLoading ? null : onUpdate,
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'প্রোফাইল আপডেট করুন',
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

