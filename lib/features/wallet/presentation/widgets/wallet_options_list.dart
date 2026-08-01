import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/core/constants/app_strings.dart';

class WalletOptionsList extends StatelessWidget {
  const WalletOptionsList({super.key});

  static const _options = [
    (Icons.analytics_outlined, 'ইনকাম সামারি', '/income-summary'),
    (Icons.confirmation_number, AppStrings.walletOption1, '/voucher-balance'),
    (Icons.payments, AppStrings.walletOption2, '/withdraw-balance'),
    (Icons.history, AppStrings.walletOption3, '/withdrawal-history'),
    (Icons.sync_alt, AppStrings.walletOption4, '/balance-transfer'),
    (Icons.receipt_long, AppStrings.walletOption5, '/all-transactions'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _options.map((opt) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingMd),
          child: _OptionItem(
            icon: opt.$1,
            label: opt.$2,
            onTap: () => context.push(opt.$3),
          ),
        );
      }).toList(),
    );
  }
}

class _OptionItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _OptionItem({required this.icon, required this.label, this.onTap});

  @override
  State<_OptionItem> createState() => _OptionItemState();
}

class _OptionItemState extends State<_OptionItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacingMd),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFEFF), // cyan-50
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFCFFAFE),
                  ), // cyan-100
                ),
                child: Icon(widget.icon, color: AppColors.cyan, size: 24),
              ),
              const SizedBox(width: AppSizes.spacingMd),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155), // slate-700
                  ),
                ),
              ),
              const Text(
                '»',
                style: TextStyle(
                  color: AppColors.cyan,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: AppColors.cyan, blurRadius: 10)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
