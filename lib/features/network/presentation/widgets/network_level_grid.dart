import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/core/constants/app_strings.dart';

import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/network/data/models/downline_user_model.dart';

class NetworkLevelGrid extends StatelessWidget {
  final UserModel user;
  final num totalTeam;
  final List<DownlineUserModel>? downlines;

  const NetworkLevelGrid({
    super.key,
    required this.user,
    required this.totalTeam,
    this.downlines,
  });

  @override
  Widget build(BuildContext context) {
    final team = user.team;

    num getCount(int level, num fallback) {
      if (downlines == null) return fallback;
      return downlines!.where((u) => u.level == level).length;
    }

    num getBusinessCount(int level, num fallback) {
      if (downlines == null) return fallback;
      return downlines!.where((u) => u.level == level && u.hasAnyActivePlan).length;
    }

    final levels = [
      {
        'title': AppStrings.networkLevel1,
        'count': getCount(1, team.level1),
        'businessCount': getBusinessCount(1, team.level1Business),
      },
      {
        'title': AppStrings.networkLevel2,
        'count': getCount(2, team.level2),
        'businessCount': getBusinessCount(2, team.level2Business),
      },
      {
        'title': AppStrings.networkLevel3,
        'count': getCount(3, team.level3),
        'businessCount': getBusinessCount(3, team.level3Business),
      },
      {
        'title': AppStrings.networkLevel4,
        'count': getCount(4, team.level4),
        'businessCount': getBusinessCount(4, team.level4Business),
      },
      {
        'title': AppStrings.networkLevel5,
        'count': getCount(5, team.level5),
        'businessCount': getBusinessCount(5, team.level5Business),
      },
      {
        'title': AppStrings.networkLevel6,
        'count': getCount(6, team.level6),
        'businessCount': getBusinessCount(6, team.level6Business),
      },
      {
        'title': AppStrings.networkLevel7,
        'count': getCount(7, team.level7),
        'businessCount': getBusinessCount(7, team.level7Business),
      },
      {
        'title': AppStrings.networkLevel8,
        'count': getCount(8, team.level8),
        'businessCount': getBusinessCount(8, team.level8Business),
      },
      {
        'title': AppStrings.networkLevel9,
        'count': getCount(9, team.level9),
        'businessCount': getBusinessCount(9, team.level9Business),
      },
      {
        'title': AppStrings.networkLevel10,
        'count': getCount(10, team.level10),
        'businessCount': getBusinessCount(10, team.level10Business),
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingXl),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: levels.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSizes.spacingMd),
        itemBuilder: (context, i) {
          final level = levels[i];
          final count = level['count'] as num;
          final progress = totalTeam > 0 ? (count / totalTeam) : 0.0;

          return _LevelCard(
            title: level['title'] as String,
            count: count,
            businessCount: level['businessCount'] as num,
            progress: progress.toDouble(),
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String title;
  final num count;
  final num businessCount;
  final double progress;

  const _LevelCard({
    required this.title,
    required this.count,
    required this.businessCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spacingSm,
        horizontal: AppSizes.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: AppColors.primary, size: 24),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildSubCount(
                      Icons.person,
                      count,
                      AppColors.onTertiaryFixedVariant,
                    ),
                    const SizedBox(width: AppSizes.spacingXs),
                    _buildSubCount(
                      Icons.business_center,
                      businessCount,
                      AppColors.onPrimaryFixedVariant,
                    ), // Business count
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceContainer,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacingMd),
          Text(
            count.toString(),
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCount(IconData icon, num count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: AppSizes.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

