import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/income_summary/data/models/income_history_model.dart';

class RecentIncomeList extends StatelessWidget {
  final List<IncomeHistoryModel> transactions;

  const RecentIncomeList({super.key, required this.transactions});

  IconData _getTypeIcon(String type) => switch (type) {
    'micro_job' => Icons.work_outline,
    'referral_bonus' => Icons.people_outline,
    'typing_job' => Icons.keyboard_outlined,
    'deposit' => Icons.account_balance_wallet_outlined,
    'daily_bonus' => Icons.today,
    'weekly_bonus' => Icons.date_range,
    'monthly_bonus' => Icons.calendar_month,
    'target_bonus' => Icons.track_changes,
    'welcome_bonus' => Icons.card_giftcard,
    'lucky_start_bonus' => Icons.waving_hand,
    'team_bonus' => Icons.groups,
    _ => Icons.attach_money,
  };

  String _formatDate(DateTime date) {
    final bdTime = date.toUtc().add(const Duration(hours: 6));
    final now = DateTime.now().toUtc().add(const Duration(hours: 6));
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(bdTime.year, bdTime.month, bdTime.day);

    final timeStr = DateFormat('hh:mm a').format(bdTime);

    if (itemDate == today) {
      return 'Today, $timeStr';
    } else if (itemDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      return '${DateFormat('dd MMM, yyyy').format(bdTime)}, $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'সাম্প্রতিক ইনকাম',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingMd),
        if (transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingXl),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: AppSizes.spacingMd),
                  Text(
                    'কোনো আয়ের তথ্য নেই',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...transactions.take(10).map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacingSm),
              child: _buildIncomeItem(
                icon: _getTypeIcon(t.type),
                title: t.description.isNotEmpty ? t.description : t.type.replaceAll('_', ' ').toUpperCase(),
                subtitle: _formatDate(t.createdAt),
                amount: '+ ৳ ${t.amount.toStringAsFixed(0)}',
                status: 'Success',
              ),
            );
          }),
      ],
    );
  }

  Widget _buildIncomeItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String status,
  }) {
    final isSuccess = status.toUpperCase() == 'SUCCESS';
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: AppSizes.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success, // Changed to green
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSuccess ? AppColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isSuccess
                        ? AppColors.white
                        : AppColors.textSecondary,
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
