import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

import 'package:global_earn/shared/widgets/pin_input_widget.dart';

class TransferDetailsForm extends StatelessWidget {
  final TextEditingController amountController;
  final double totalBalance;
  final VoidCallback onTransferAll;
  final Function(String) onPinComplete;
  final Function(String) onPinChanged;

  const TransferDetailsForm({
    super.key,
    required this.amountController,
    required this.totalBalance,
    required this.onTransferAll,
    required this.onPinComplete,
    required this.onPinChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAmountField(),
        const SizedBox(height: AppSizes.spacingLg),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'আপনার পিন দিন',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        PinInputWidget(
          onComplete: onPinComplete,
          onChanged: onPinChanged,
        ),
        const SizedBox(height: AppSizes.spacingLg),
        Container(
          padding: const EdgeInsets.all(AppSizes.spacingSm),
          decoration: BoxDecoration(
            color: AppColors.surfaceDim.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield, color: AppColors.textSecondary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'নিরাপত্তার জন্য আপনার পিন গোপন রাখুন। ন্যূনতম ট্রান্সফার ৳ ১০০। ভুল অ্যাকাউন্টে টাকা পাঠানোর জন্য কোম্পানি দায়ী নয়।',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'ট্রান্সফারের পরিমাণ (৳)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onTransferAll,
              child: const Padding(
                padding: EdgeInsets.only(right: 4, bottom: 8),
                child: Text(
                  'সবগুলো ট্রান্সফার করুন',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            border: Border.all(color: AppColors.outline),
          ),
          child: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: '৳100 - ৳${totalBalance.toStringAsFixed(0)}',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              prefixIcon: const Icon(
                Icons.payments,
                color: AppColors.primary,
              ),
              suffixIcon: Container(
                padding: const EdgeInsets.only(right: 16),
                alignment: Alignment.centerRight,
                width: 60,
                child: const Text(
                  'BDT',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ),
      ],
    );
  }

}
