import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

class WarningHeader extends StatelessWidget {
  const WarningHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outline),
          ),
          child: const Center(
            child: Icon(
              Icons.warning_rounded,
              size: 48,
              color: AppColors.error,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        Text(
          'একাউন্ট মুছে ফেলুন',
          style: GoogleFonts.manrope(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingBase),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingLg),
          child: Text(
            'আপনি কি নিশ্চিত যে আপনি আপনার একাউন্টটি স্থায়ীভাবে মুছে ফেলতে চান?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
