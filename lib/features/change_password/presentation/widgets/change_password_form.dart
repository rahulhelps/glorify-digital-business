import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/change_password/presentation/bloc/change_password_bloc.dart';
import 'package:global_earn/features/change_password/presentation/bloc/change_password_event.dart';
import 'package:global_earn/features/change_password/presentation/bloc/change_password_state.dart';

class ChangePasswordForm extends StatefulWidget {
  final TextEditingController currentController;
  final TextEditingController newController;
  final TextEditingController confirmController;

  const ChangePasswordForm({
    super.key,
    required this.currentController,
    required this.newController,
    required this.confirmController,
  });

  @override
  State<ChangePasswordForm> createState() => ChangePasswordFormState();
}

class ChangePasswordFormState extends State<ChangePasswordForm> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _onChanged() {
    context.read<ChangePasswordBloc>().add(
      PasswordFieldChanged(
        current: widget.currentController.text,
        newPass: widget.newController.text,
        confirm: widget.confirmController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        bool isMinLength = false;
        bool isMatch = true;
        bool showMatchHint = widget.confirmController.text.isNotEmpty;

        if (state is ChangePasswordValid) {
          isMinLength = state.isMinLength;
          isMatch = state.isMatch;
        } else if (state is ChangePasswordInvalid) {
          isMinLength = state.isMinLength;
          isMatch = state.isMatch;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(
              controller: widget.currentController,
              hint: 'বর্তমান পাসওয়ার্ড',
              icon: Icons.lock_open,
              isObscured: _obscureCurrent,
              onToggleVisibility: () {
                setState(() => _obscureCurrent = !_obscureCurrent);
              },
            ),
            const SizedBox(height: AppSizes.spacingMd),
            _buildPasswordField(
              controller: widget.newController,
              hint: 'নতুন পাসওয়ার্ড',
              icon: Icons.lock_outline,
              isObscured: _obscureNew,
              onToggleVisibility: () {
                setState(() => _obscureNew = !_obscureNew);
              },
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'কমপক্ষে ৮ অক্ষর হতে হবে',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isMinLength ? AppColors.success : AppColors.error,
                  fontWeight: isMinLength ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),
            _buildPasswordField(
              controller: widget.confirmController,
              hint: 'পাসওয়ার্ড নিশ্চিত করুন',
              icon: Icons.verified_user_outlined,
              isObscured: _obscureConfirm,
              onToggleVisibility: () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              },
            ),
            if (showMatchHint && !isMatch) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  'পাসওয়ার্ড মিলছে না',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.spacingMd),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.spacingXs),
                Expanded(
                  child: Text(
                    'পাসওয়ার্ড অবশ্যই কমপক্ষে ৮ অক্ষরের হতে হবে।',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.outline),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        onChanged: (_) => _onChanged(),
        style: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(
              isObscured ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
            ),
            onPressed: onToggleVisibility,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingMd,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
