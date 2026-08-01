import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

class PaymentMethodGrid extends StatelessWidget {
  final String? selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodGrid({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  final List<Map<String, dynamic>> _methods = const [
    {'name': 'bKash', 'image': 'assets/images/bkash_logo.jpg'},
    {'name': 'Nagad', 'image': 'assets/images/nagad_logo.jpg'},
    {'name': 'Rocket', 'image': 'assets/images/rocket_logo.webp'},
    {'name': 'Bank', 'icon': Icons.account_balance},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'পেমেন্ট মেথড নির্বাচন করুন',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: AppSizes.spacingSm,
            mainAxisSpacing: AppSizes.spacingSm,
            childAspectRatio: 0.85,
          ),
          itemCount: _methods.length,
          itemBuilder: (context, index) {
            final method = _methods[index];
            final isSelected = selectedMethod == method['name'];

            return GestureDetector(
              onTap: () => onMethodSelected(method['name']),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.outline,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      ),
                      child: method.containsKey('image')
                          ? Image.asset(method['image'], fit: BoxFit.contain)
                          : Icon(
                              method['icon'],
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 32,
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method['name'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
