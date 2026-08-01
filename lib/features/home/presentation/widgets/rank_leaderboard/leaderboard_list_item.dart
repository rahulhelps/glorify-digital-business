import 'package:flutter/material.dart';
import 'package:global_earn/features/home/domain/models/leaderboard_user_model.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'leaderboard_avatar.dart';

class LeaderboardListItem extends StatelessWidget {
  final LeaderboardUserModel user;
  final int position;
  final bool isCurrentUser;

  const LeaderboardListItem({
    super.key,
    required this.user,
    required this.position,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              position.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          LeaderboardAvatar(
            imageUrl: user.profileImageUrl,
            name: user.name,
            size: 48,
            borderColor: const Color(0xFFFFD700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            user.rankCount.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
