import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/wallet/presentation/bloc/voucher_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/voucher_state.dart';
import 'package:global_earn/features/wallet/presentation/widgets/voucher_balance_card.dart';
import 'package:global_earn/features/wallet/presentation/widgets/voucher_action_buttons.dart';
import 'package:global_earn/features/wallet/presentation/widgets/recent_vouchers_list.dart';
import 'package:global_earn/shared/widgets/verification_guard.dart';

class VoucherBalanceScreen extends StatefulWidget {
  const VoucherBalanceScreen({super.key});

  @override
  State<VoucherBalanceScreen> createState() => _VoucherBalanceScreenState();
}

class _VoucherBalanceScreenState extends State<VoucherBalanceScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VerificationGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'ভাউচার ব্যালেন্স',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => context.push('/wallet/voucher-history'),
            tooltip: 'হিস্ট্রি',
          ),
        ],
      ),
      body: BlocListener<VoucherBloc, VoucherState>(
        listener: (context, state) {
          if (state is VoucherSuccess) {
            if (state.code != null) {
              _showVoucherCodeDialog(context, state.code!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } else if (state is VoucherError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.marginMobile,
            vertical: AppSizes.spacingLg,
          ),
          child: const Column(
            children: [
              VoucherBalanceCard(),
              SizedBox(height: AppSizes.spacingLg),
              VoucherActionButtons(),
              SizedBox(height: AppSizes.spacingLg),
              RecentVouchersList(),
            ],
          ),
        ),
      ),
    ));
  }

  void _showVoucherCodeDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('ভাউচার কেনা সফল!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'আপনার ভাউচার কোড:',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'এই কোডটি যেকোনো user রিডিম করতে পারবে',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('কোড কপি করা হয়েছে')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('কোড কপি করুন'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বন্ধ করুন'),
          ),
        ],
      ),
    );
  }
}
