import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:global_earn/features/profile/presentation/bloc/profile_event.dart';

/// Gradient banner header with centered avatar, camera badge,
/// user name (white, bold) and optional verified badge.
///
/// Layout (top → bottom, all centered):
///   ┌──────────────────────────────────────────┐  ← gradient card h=230
///   │                                          │
///   │          ╔══════════════╗                │
///   │          ║   avatar     ║  ← 120×120     │
///   │          ║         [📷] ║  ← camera badge│
///   │          ╚══════════════╝                │
///   │           UserName  [✓]                  │
///   │           +62 8xx-xxxx-xxxx              │
///   │                                          │
///   └────────────────────────────── ───────────┘ ← br 28
class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  // ── Image picker — logic unchanged ─────────────────────────────────────────
  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && context.mounted) {
      context.read<ProfileBloc>().add(
        UpdateProfilePhoto(uid: user.uid, imageFile: File(pickedFile.path)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 120.0;
    const double badgeSize = 32.0;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        // Extra bottom padding so name+phone have breathing room
        padding: const EdgeInsets.only(bottom: 28),
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),

              // ── Avatar + camera badge ─────────────────────────────────────
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // White ring + avatar
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: user.profileImageUrl != null
                          ? Image.network(
                              user.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.person,
                                size: 56,
                                color: AppColors.textSecondary,
                              ),
                            )
                          : Container(
                              color: AppColors.surfaceContainerHigh,
                              child: const Icon(
                                Icons.person,
                                size: 56,
                                color: AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),

                  // Camera badge — bottom-right of avatar
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(context),
                      child: Container(
                        width: badgeSize,
                        height: badgeSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 17,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Name + verified badge ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      user.name,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 4),

              // ── Phone number (real, from user.phone) ─────────────────────
              Text(
                user.phone,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
