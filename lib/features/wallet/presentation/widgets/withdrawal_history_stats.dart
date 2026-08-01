import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

import 'package:global_earn/features/auth/data/models/user_model.dart';

class WithdrawalHistoryStats extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final UserModel user;

  const WithdrawalHistoryStats({
    super.key,
    required this.requests,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final double totalWithdrawn = requests
        .where((r) => r['status'] == 'approved' || r['status'] == 'success')
        .fold(0.0, (sum, r) => sum + (r['amount'] ?? 0.0).toDouble());

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.spacingMd,
      mainAxisSpacing: AppSizes.spacingMd,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          label: 'Total Withdrawn',
          value: '৳ ${totalWithdrawn.toStringAsFixed(0)}',
          valueColor: AppColors.secondary,
        ),
        _StatCard(
          label: 'Balance',
          value: '৳ ${user.withdrawableBalance.toStringAsFixed(2)}',
          icon: Icons.account_balance_wallet,
          iconColor: AppColors.primaryContainer,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final Color? iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (icon != null)
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.1,
                child: Icon(icon, size: 64, color: iconColor),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
