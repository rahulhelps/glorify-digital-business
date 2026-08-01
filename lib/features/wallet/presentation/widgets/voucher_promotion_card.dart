import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

class VoucherPromotionCard extends StatelessWidget {
  const VoucherPromotionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radius3xl),
        color: AppColors.surface,
        border: Border.all(color: AppColors.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radius3xl),
        child: Stack(
          children: [
            Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida/ADBb0ugLIvMNeRrOYiyKxl98Eua2uLMVqE9bZj5uzTb_fa5TIfWJUNv0EBKEXxf9OurQ83iN6w7LNRm8Xh2hTWJEhfLPhVIMdmlqFShdz8clXTy4HO-jpv2wJrderIRcMXPFe0kt_awDzKogS-2wQN_MWlvJNAsh3l-QBkpcJlLfXdIrdjRaNE1qtAt9qfFmx-X5i8BujuFmZoOBNKhv0MQjBl8lGbiV5qIrKGJsOrdVVMb7HfTp-DL0e9vCOrKIXEYrm_zxMUxt5D_pv_0',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingLg,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SPECIAL OFFER',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    'Get 20% Cashback',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'On your next voucher purchase',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
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
