import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

class TransactionListItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String status;
  final IconData icon;
  final Color color;
  final bool isPending;

  const TransactionListItem({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    required this.icon,
    required this.color,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPending ? AppColors.textPrimary : color,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingXs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isPending
                      ? AppColors.surfaceDim
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                  border: Border.all(
                    color: isPending
                        ? AppColors.outline
                        : color.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPending ? AppColors.textSecondary : color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
