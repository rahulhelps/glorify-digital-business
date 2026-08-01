import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';

/// Avatar widget for the leaderboard — podium (top 3) and list items (rank 4+).
///
/// Loading state → centred [CircularProgressIndicator] inside avatar circle.
/// Error / empty URL → first letter of [name] in a solid [AppColors.primary] circle.
/// Success → clipped network image.
class LeaderboardAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color borderColor;
  final bool doubleRing;

  const LeaderboardAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.size,
    required this.borderColor,
    this.doubleRing = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: ClipOval(child: _buildAvatar(name, imageUrl ?? '', size)),
    );

    if (!doubleRing) return avatar;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 2),
      ),
      child: avatar,
    );
  }

  Widget _buildAvatar(String name, String imageUrl, double size) {
    if (imageUrl.isEmpty) {
      return _buildInitialAvatar(name, size);
    }
    return Image.network(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: size,
          height: size,
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => _buildInitialAvatar(name, size),
    );
  }

  Widget _buildInitialAvatar(String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}
