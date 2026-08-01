import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:global_earn/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:global_earn/features/wallet/presentation/widgets/wallet_balance_card.dart';
import 'package:global_earn/features/wallet/presentation/widgets/wallet_options_list.dart';
import 'package:global_earn/service_locator.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<WalletBloc>()..add(const WalletStarted()),
      child: const WalletView(),
    );
  }
}

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<WalletBloc, WalletState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.coral),
            );
          }

          if (state is WalletError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacingLg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSizes.spacingMd),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingLg),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<WalletBloc>().add(const WalletStarted()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('আবার চেষ্টা করুন'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is WalletLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile,
                vertical: AppSizes.spacingLg,
              ),
              child: Column(
                children: [
                  WalletBalanceCard(user: state.user),
                  const SizedBox(height: AppSizes.spacingLg),
                  const WalletOptionsList(),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
