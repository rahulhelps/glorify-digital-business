import 'package:flutter/material.dart';
import 'package:global_earn/features/home/domain/models/leaderboard_user_model.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'leaderboard_avatar.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardUserModel> topThree;

  const LeaderboardPodium({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    final first = topThree[0];
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _PodiumItem(user: second, position: 2)),
        Expanded(child: _PodiumItem(user: first, position: 1)),
        Expanded(child: _PodiumItem(user: third, position: 3)),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardUserModel? user;
  final int position;

  const _PodiumItem({required this.user, required this.position});

  @override
  Widget build(BuildContext context) {
    final isFirst = position == 1;
    final size = isFirst ? 80.0 : 65.0;

    Color borderColor;
    if (position == 1) {
      borderColor = const Color(0xFFFFD700);
    } else if (position == 2) {
      borderColor = const Color(0xFFC0C0C0);
    } else {
      borderColor = const Color(0xFFCD7F32);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst) const Text('🥇 ⭐', style: TextStyle(fontSize: 20)),
        if (!isFirst)
          Text(
            position.toString().padLeft(2, '0'),
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 8),
        if (user != null)
          LeaderboardAvatar(
            imageUrl: user!.profileImageUrl,
            name: user!.name,
            size: size,
            borderColor: borderColor,
            doubleRing: isFirst,
          )
        else
          SizedBox(height: size, width: size),
        const SizedBox(height: 8),
        if (user != null) ...[
          Text(
            user!.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            user!.rankCount.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
