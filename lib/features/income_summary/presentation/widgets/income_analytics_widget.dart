import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/income_summary/data/models/income_summary_model.dart';

class IncomeAnalyticsWidget extends StatelessWidget {
  final IncomeSummaryModel summary;

  const IncomeAnalyticsWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    // Determine the max amount for scaling the bars.
    double maxAmount = 1;
    if (summary.byDay.isNotEmpty) {
      final values = summary.byDay.values;
      final maxVal = values.reduce((curr, next) => curr > next ? curr : next);
      maxAmount = maxVal > 0 ? maxVal : 1;
    }

    final bdOffset = const Duration(hours: 6);
    final now = DateTime.now().toUtc().add(bdOffset);
    final List<Widget> bars = [];
    final List<Widget> labels = [];

    // Keys are 'YYYY-M-D', from oldest (6 days ago) to newest (today)
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      final amount = summary.byDay[key] ?? 0;
      final heightFactor = amount == 0 ? 0.0 : (amount / maxAmount).clamp(0.05, 1.0);
      final isActive = i == 0;

      bars.add(_buildBar(heightFactor, isActive: isActive));
      labels.add(_buildDayLabel(DateFormat('E').format(date), isBold: isActive));
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Last 7 Days',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Text(
                  'Week',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingLg),
          SizedBox(
            height: 192,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 1,
                      color: AppColors.outline.withValues(alpha: 0.3),
                    ),
                    Container(
                      height: 1,
                      color: AppColors.outline.withValues(alpha: 0.3),
                    ),
                    Container(
                      height: 1,
                      color: AppColors.outline.withValues(alpha: 0.3),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: bars,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels,
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, {required bool isActive}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FractionallySizedBox(
          heightFactor: heightFactor,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayLabel(String label, {bool isBold = false}) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
