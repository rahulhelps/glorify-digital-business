import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/wallet/presentation/bloc/withdraw_bloc.dart';

class WithdrawBottomAction extends StatelessWidget {
  final VoidCallback? onPressed;
  const WithdrawBottomAction({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.marginMobile),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.8),
        border: const Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        child: BlocBuilder<WithdrawBloc, WithdrawState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            final isLoading = state is WithdrawLoading;

            return Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                gradient: const LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'উত্তোলন সম্পন্ন করুন',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
