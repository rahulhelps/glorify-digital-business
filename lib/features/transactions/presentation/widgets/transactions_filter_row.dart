import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

class TransactionsFilterRow extends StatelessWidget {
  const TransactionsFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', isSelected: true),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip('In', isSelected: false),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip('Out', isSelected: false),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip('Pending', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingLg,
        vertical: AppSizes.spacingSm,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
