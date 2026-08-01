import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_history_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_history_event.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_history_state.dart';
import 'package:global_earn/features/wallet/presentation/widgets/transaction_history_filters.dart';
import 'package:global_earn/features/wallet/presentation/widgets/transaction_history_summary.dart';
import 'package:global_earn/features/wallet/presentation/widgets/transaction_history_list.dart';
import 'package:global_earn/service_locator.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    String uid = '';
    if (userState is UserLoaded) {
      uid = userState.user.uid;
    }

    return BlocProvider(
      create: (context) =>
          sl<TransferHistoryBloc>()..add(LoadTransferHistory(uid)),
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
            'ট্রান্সফার হিস্ট্রি',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<TransferHistoryBloc, TransferHistoryState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state is TransferHistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is TransferHistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: AppSizes.spacingMd),
                    ElevatedButton(
                      onPressed: () => context.read<TransferHistoryBloc>().add(
                        LoadTransferHistory(uid),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile,
                vertical: AppSizes.spacingLg,
              ),
              child: Column(
                children: [
                  TransactionHistoryFilters(),
                  SizedBox(height: AppSizes.spacingMd),
                  TransactionHistorySummary(),
                  SizedBox(height: AppSizes.spacingMd),
                  TransactionHistoryList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
