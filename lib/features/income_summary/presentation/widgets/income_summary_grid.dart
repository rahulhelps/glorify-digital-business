import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/income_summary/data/models/income_summary_model.dart';

class IncomeSummaryGrid extends StatelessWidget {
  final IncomeSummaryModel summary;
  
  const IncomeSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    // Total income is the sum of all transactions, not just month/week.
    final total = summary.transactions.fold<double>(0, (sum, item) => sum + item.amount);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _buildDailyIncome(summary.todayTotal),
          const SizedBox(width: AppSizes.spacingMd),
          _buildMonthlyIncome(summary.monthTotal),
          const SizedBox(width: AppSizes.spacingMd),
          _buildTotalIncome(total),
        ],
      ),
    );
  }

  Widget _buildDailyIncome(double amount) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.payments_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              Text(
                'Daily',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Text(
            '৳ ${amount.toStringAsFixed(0)}',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          Container(
            height: 4,
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.transparent),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.66,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyIncome(double amount) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              Text(
                'Monthly',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Text(
            '৳ ${amount.toStringAsFixed(0)}',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          Container(
            height: 4,
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.transparent),
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalIncome(double amount) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              Text(
                'Total',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Text(
            '৳ ${amount.toStringAsFixed(0)}',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: AppColors.secondary,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                '+12.5%',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
