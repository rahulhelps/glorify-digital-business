import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/network/data/models/downline_user_model.dart';

class DownlineUserCard extends StatelessWidget {
  final DownlineUserModel user;

  const DownlineUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final joinDate = DateFormat('dd MMM yyyy').format(user.joinedAt);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.marginMobile,
        vertical: AppSizes.spacingBase,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        side: const BorderSide(color: AppColors.outline),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSizes.spacingMd),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row
                  Text(
                    user.name,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Phone
                  _InfoRow(
                    icon: '📱',
                    text: user.phone.isNotEmpty ? user.phone : '—',
                  ),

                  // Refer code
                  _InfoRow(
                    icon: '🔗',
                    text: user.referCode.isNotEmpty ? user.referCode : '—',
                  ),

                  // Join date
                  _InfoRow(icon: '📅', text: joinDate),

                  const SizedBox(height: AppSizes.spacingXs),

                  // Badges row
                  Row(
                    children: [
                      _LevelBadge(level: user.level),
                      const SizedBox(width: AppSizes.spacingXs),
                      _StatusBadge(user: user),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper widgets ──────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        'লেভেল $level',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DownlineUserModel user;

  const _StatusBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.isVerified) {
      return _Pill(
        label: '✅ ৳৩২০ ভেরিফাইড',
        bg: const Color(0xFF0BA360).withValues(alpha: 0.15),
        fg: const Color(0xFF0BA360),
      );
    } else if (user.isPending) {
      return _Pill(
        label: '⏳ পর্যালোচনাধীন',
        bg: const Color(0xFFFFF3E0),
        fg: const Color(0xFFE65100),
      );
    } else {
      return _Pill(
        label: 'সাধারণ',
        bg: AppColors.textSecondary.withValues(alpha: 0.1),
        fg: AppColors.textSecondary,
      );
    }
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Pill({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

