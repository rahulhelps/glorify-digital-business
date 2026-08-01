import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/wallet/presentation/bloc/withdraw_bloc.dart';

class WithdrawInputFields extends StatelessWidget {
  final TextEditingController accountController;
  final TextEditingController amountController;
  final TextEditingController bankNameController;
  final String? selectedMethod;
  final UserModel user;
  final int minWithdrawal;
  final int maxWithdrawal;
  final int firstTimeWithdrawal;

  const WithdrawInputFields({
    super.key,
    required this.accountController,
    required this.amountController,
    required this.bankNameController,
    required this.selectedMethod,
    required this.user,
    required this.minWithdrawal,
    required this.maxWithdrawal,
    required this.firstTimeWithdrawal,
  });

  @override
  Widget build(BuildContext context) {
    final double maxBalance = user.withdrawableBalance;
    final double effectiveMax = maxBalance < maxWithdrawal.toDouble() ? maxBalance : maxWithdrawal.toDouble();
    final bool isBank = selectedMethod == 'Bank';
    
    final double minimumAmount = user.hasWithdrawnBefore ? minWithdrawal.toDouble() : firstTimeWithdrawal.toDouble();
    final String minimumHint = user.hasWithdrawnBefore 
        ? 'সর্বনিম্ন উত্তোলন: ৳$minWithdrawal' 
        : 'সর্বনিম্ন উত্তোলন: ৳$firstTimeWithdrawal (প্রথমবার বিশেষ সুবিধা)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isBank) ...[
          _buildInputField(
            label: 'ব্যাংকের নাম',
            hint: 'Sonali Bank, Dutch-Bangla etc.',
            icon: Icons.business,
            controller: bankNameController,
          ),
          const SizedBox(height: AppSizes.spacingLg),
          _buildInputField(
            label: 'একাউন্ট নম্বর',
            hint: 'XXXXXXXXXXXX',
            icon: Icons.account_balance,
            controller: accountController,
            isNumber: true,
          ),
        ] else ...[
          _buildInputField(
            label: 'মোবাইল নম্বর দিন',
            hint: '017XXXXXXXX',
            icon: Icons.dialpad,
            controller: accountController,
            isNumber: true,
          ),
        ],
        const SizedBox(height: AppSizes.spacingLg),
        _buildInputField(
          label: 'উত্তোলনের পরিমাণ (৳)',
          hint: '৳${minimumAmount.toStringAsFixed(0)} - ৳${effectiveMax.toStringAsFixed(0)}',
          icon: Icons.payments,
          isNumber: true,
          controller: amountController,
          onChanged: (val) {
            context.read<WithdrawBloc>().add(AmountChangedEvent(val));
          },
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minimumHint,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final text = effectiveMax.toStringAsFixed(2);
                  amountController.text = text;
                  context.read<WithdrawBloc>().add(AmountChangedEvent(text));
                },
                child: const Text(
                  'সবগুলো উত্তোলন করুন',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isNumber = false,
    Widget? footer,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            border: Border.all(color: AppColors.outline),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(
                icon,
                color: AppColors.secondary.withValues(alpha: 0.6),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        if (footer != null) ...[const SizedBox(height: 4), footer],
      ],
    );
  }
}
