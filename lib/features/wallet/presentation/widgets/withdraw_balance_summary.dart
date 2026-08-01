import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';

class WithdrawBalanceSummary extends StatelessWidget {
  final UserModel user;
  const WithdrawBalanceSummary({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final double withdrawableBalance = user.withdrawableBalance;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingSm),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.spacingMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'উত্তোলনযোগ্য ব্যালেন্স',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '৳ $withdrawableBalance',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                width: 2,
              ),
              image: user.profileImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(user.profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.profileImageUrl == null
                ? const Icon(Icons.person, color: AppColors.textSecondary)
                : null,
          ),
        ],
      ),
    );
  }
}
