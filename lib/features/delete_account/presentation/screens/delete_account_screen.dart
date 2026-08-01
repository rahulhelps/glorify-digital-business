import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:global_earn/features/auth/presentation/bloc/auth_event.dart';
import 'package:global_earn/features/delete_account/presentation/bloc/delete_account_bloc.dart';
import 'package:global_earn/features/delete_account/presentation/bloc/delete_account_event.dart';
import 'package:global_earn/features/delete_account/presentation/bloc/delete_account_state.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_event.dart';
import 'package:global_earn/shared/widgets/app_text_field.dart';
import 'package:global_earn/service_locator.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isChecked = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'অ্যাকাউন্ট মুছুন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'আপনি কি নিশ্চিত যে আপনি আপনার অ্যাকাউন্ট মুছে ফেলতে চান? এটি পুনরায় ফিরিয়ে আনা সম্ভব নয়।',
          style: GoogleFonts.hindSiliguri(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'বাতিল করুন',
              style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DeleteAccountBloc>().add(
                SubmitDeleteAccount(_passwordController.text),
              );
            },
            child: Text(
              'হ্যাঁ, মুছে ফেলুন',
              style: GoogleFonts.hindSiliguri(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeleteAccountBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: Text(
            'অ্যাকাউন্ট মুছুন',
            style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocListener<DeleteAccountBloc, DeleteAccountState>(
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('আপনার অ্যাকাউন্ট সফলভাবে মুছে ফেলা হয়েছে', style: GoogleFonts.hindSiliguri(color: Colors.white)),
                  backgroundColor: AppColors.success,
                ),
              );
              context.read<UserBloc>().add(UserClearedEvent());
              context.read<AuthBloc>().add(AuthLogoutRequested());
              context.go('/login');
            } else if (state.status == DeleteAccountStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: GoogleFonts.hindSiliguri(color: Colors.white)),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: BlocBuilder<DeleteAccountBloc, DeleteAccountState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              final isEnabled =
                  _passwordController.text.isNotEmpty &&
                  _confirmController.text.isNotEmpty &&
                  _passwordController.text == _confirmController.text &&
                  _isChecked &&
                  !state.isSubmitting;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.marginMobile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWarningSection(),
                    const SizedBox(height: AppSizes.spacingLg),
                    AppTextField(
                      hint: 'পাসওয়ার্ড',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      obscure: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSizes.spacingMd),
                    AppTextField(
                      hint: 'পাসওয়ার্ড নিশ্চিত করুন',
                      icon: Icons.lock_outline,
                      controller: _confirmController,
                      obscure: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSizes.spacingLg),
                    _buildCheckboxSection(),
                    const SizedBox(height: 48),
                    _buildActionButtons(context, isEnabled, state.isSubmitting),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWarningSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: AppSizes.spacingSm),
          Text(
            'সতর্কতা!',
            style: GoogleFonts.hindSiliguri(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Text(
            'আপনি যদি অ্যাকাউন্ট মুছে ফেলেন, তবে আপনার সমস্ত ডেটা স্থায়ীভাবে মুছে ফেলা হবে।',
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxSection() {
    return Row(
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: (val) => setState(() => _isChecked = val ?? false),
          activeColor: AppColors.error,
        ),
        Expanded(
          child: Text(
            'আমি নিশ্চিত এবং আমার অ্যাকাউন্ট মুছে ফেলতে চাই',
            style: GoogleFonts.hindSiliguri(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    bool isEnabled,
    bool isLoading,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isEnabled
                ? () => _showDeleteConfirmation(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? AppColors.error
                  : Colors.grey.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              elevation: isEnabled ? 4 : 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'অ্যাকাউন্ট মুছুন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'বাতিল করুন',
            style: GoogleFonts.hindSiliguri(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

