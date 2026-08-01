import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import '../../data/models/income_history_model.dart';

class IncomeTransactionItem extends StatelessWidget {
  final IncomeHistoryModel transaction;

  const IncomeTransactionItem({super.key, required this.transaction});

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'referral':
        return Icons.people_alt;
      case 'task':
        return Icons.task_alt;
      case 'bonus':
        return Icons.card_giftcard;
      case 'lucky_start_bonus':
        return Icons.waving_hand;
      case 'ads_view':
        return Icons.play_circle_outline;
      default:
        return Icons.attach_money;
    }
  }

  String _getTypeBadgeText(String type) {
    switch (type) {
      case 'referral':
        return 'রেফারেল';
      case 'task':
        return 'কাজ';
      case 'bonus':
        return 'বোনাস';
      case 'lucky_start_bonus':
        return 'লাকি স্টার্ট বোনাস';
      case 'ads_view':
        return 'এড ভিউ';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bdTime = transaction.createdAt.toUtc().add(const Duration(hours: 6));
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(bdTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(transaction.type),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
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
                '+৳${transaction.amount.toStringAsFixed(2)}',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getTypeBadgeText(transaction.type),
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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
