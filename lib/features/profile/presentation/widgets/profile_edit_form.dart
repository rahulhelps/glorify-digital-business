import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';

/// Personal information form — label-above-field style.
///
/// Changes from previous version:
///  • Section heading: centered, plain bold, no icon prefix
///  • Each field: label above (bold, dark) + light grey rounded box below
///  • No prefixIcon inside the text field
///  • Read-only fields (phone, email) show a caption hint below the box
///  • All data sources (controllers, user.email, user.referCode, joinDate)
///    are unchanged — only the visual container is restyled
class ProfileEditForm extends StatelessWidget {
  final UserModel user;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController bioController; // Kept bioController to avoid breaking parent state, though unused.
  final DateTime? selectedDateOfBirth;
  final VoidCallback? onTapDateOfBirth;

  const ProfileEditForm({
    super.key,
    required this.user,
    required this.nameController,
    required this.phoneController,
    required this.bioController,
    this.selectedDateOfBirth,
    this.onTapDateOfBirth,
  });

  @override
  Widget build(BuildContext context) {
    final formattedJoinDate = DateFormat('MMM yyyy').format(user.joinedAt);
    final dobFormatted = selectedDateOfBirth != null
        ? DateFormat('dd-MM-yyyy').format(selectedDateOfBirth!)
        : 'আপনার জন্ম তারিখ নির্বাচন করুন';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Section heading ───────────────────────────────────────────────
        Text(
          'ব্যক্তিগত তথ্য',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSizes.spacingMd),

        // ── Editable: Full name ───────────────────────────────────────────
        _buildField(
          label: 'পুরো নাম',
          controller: nameController,
        ),

        const SizedBox(height: AppSizes.spacingMd),

        // ── Read-only: Mobile number ──────────────────────────────────────
        _buildField(
          label: 'মোবাইল নম্বর',
          controller: phoneController,
          readOnly: true,
          caption: 'মোবাইল নম্বর পরিবর্তন করা সম্ভব নয়',
        ),

        const SizedBox(height: AppSizes.spacingMd),

        // ── Read-only: Affiliate ID ───────────────────────────────────────
        _buildField(
          label: 'অ্যাফিলিয়েট আইডি',
          value: user.referCode.isNotEmpty ? user.referCode : 'N/A',
          readOnly: true,
        ),

        const SizedBox(height: AppSizes.spacingMd),

        // ── Read-only: Join date ──────────────────────────────────────────
        _buildField(
          label: 'যোগদানের তারিখ',
          value: formattedJoinDate,
          readOnly: true,
        ),

        const SizedBox(height: AppSizes.spacingMd),

        // ── Read-only: Email ──────────────────────────────────────────────
        _buildField(
          label: 'ইমেইল',
          value: user.email.isNotEmpty ? user.email : 'ইমেইল ঠিকানা দিন',
          readOnly: true,
        ),

        const SizedBox(height: AppSizes.spacingMd),

        // ── Editable/Placeholder: DOB ─────────────────────────────────────
        GestureDetector(
          onTap: onTapDateOfBirth,
          child: AbsorbPointer(
            child: _buildField(
              label: 'জন্ম তারিখ',
              value: dobFormatted,
              readOnly: true, // Assuming not currently editable without a date picker
            ),
          ),
        ),
      ],
    );
  }

  // ── Field builder ─────────────────────────────────────────────────────────

  Widget _buildField({
    required String label,
    TextEditingController? controller,
    String? value,
    bool readOnly = false,
    int? maxLines = 1,
    String? caption,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Input box — soft grey, rounded, no border
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6), // Soft grey background
            borderRadius: BorderRadius.circular(14), // Fully rounded corners
            border: Border.all(
              color: Colors.transparent, // Borderless/minimal outline
              width: 0,
            ),
          ),
          child: TextField(
            controller:
                controller ??
                (value != null
                    ? TextEditingController(text: value)
                    : null),
            readOnly: readOnly,
            maxLines: maxLines,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: readOnly
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              // No prefixIcon
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),

        // Optional caption below read-only fields
        if (caption != null) ...[
          const SizedBox(height: 4),
          Text(
            caption,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
