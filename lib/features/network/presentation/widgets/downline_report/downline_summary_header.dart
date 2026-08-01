import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

class DownlineSummaryHeader extends StatelessWidget {
  final int total;
  final int premium;
  final int normal;

  const DownlineSummaryHeader({
    super.key,
    required this.total,
    required this.premium,
    required this.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.marginMobile,
        AppSizes.spacingMd,
        AppSizes.marginMobile,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: AppSizes.spacingMd,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondaryFixedDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatChip(
            label: '???',
            value: total,
            icon: Icons.groups_rounded,
            color: AppColors.white,
          ),
          _Divider(),
          _StatChip(
            label: '??????????',
            value: premium,
            icon: Icons.star_rounded,
            color: AppColors.gold,
          ),
          _Divider(),
          _StatChip(
            label: '??????',
            value: normal,
            icon: Icons.person_outline_rounded,
            color: AppColors.white.withValues(alpha: 0.75),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.white.withValues(alpha: 0.25),
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacingMd),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: color.withValues(alpha: 0.85), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

