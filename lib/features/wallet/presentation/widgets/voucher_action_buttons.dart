import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/wallet/presentation/widgets/purchase_voucher_sheet.dart';
import 'package:global_earn/features/wallet/presentation/widgets/redeem_voucher_dialog.dart';

class VoucherActionButtons extends StatelessWidget {
  const VoucherActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.shopping_cart_outlined,
            label: 'ভাউচার কিনুন',
            color: AppColors.primary,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const PurchaseVoucherSheet(),
              );
            },
            hasGlow: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionButton(
            icon: Icons.redeem_outlined,
            label: 'রিডিম করুন',
            color: AppColors.primary,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const RedeemVoucherDialog(),
              );
            },
            isOutline: true,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool hasGlow;
  final bool isOutline;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.hasGlow = false,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: isOutline ? Colors.white : color,
          borderRadius: BorderRadius.circular(16),
          border: isOutline ? Border.all(color: color, width: 1.5) : null,
          boxShadow: hasGlow && !isOutline
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isOutline ? color : Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isOutline ? color : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
