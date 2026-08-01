import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/wallet/presentation/bloc/withdraw_history_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/withdraw_history_event.dart';
import 'package:global_earn/features/wallet/presentation/bloc/withdraw_history_state.dart';
import 'package:global_earn/features/wallet/presentation/widgets/withdrawal_history_filters.dart';
import 'package:global_earn/features/wallet/presentation/widgets/withdrawal_history_stats.dart';
import 'package:global_earn/features/wallet/presentation/widgets/withdrawal_history_list.dart';
import 'package:global_earn/service_locator.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  State<WithdrawalHistoryScreen> createState() =>
      _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    if (userState is! UserLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider(
      create: (context) =>
          sl<WithdrawHistoryBloc>()
            ..add(LoadWithdrawHistory(userState.user.uid)),
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
            'উত্তোলনের হিস্ট্রি',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/withdraw-balance'),
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
        body: BlocBuilder<WithdrawHistoryBloc, WithdrawHistoryState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state is WithdrawHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WithdrawHistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<WithdrawHistoryBloc>().add(
                        LoadWithdrawHistory(userState.user.uid),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is WithdrawHistoryLoaded) {
              final allRequests = state.requests;
              final filteredRequests = _selectedFilter == 'All'
                  ? allRequests
                  : allRequests
                        .where(
                          (r) =>
                              r['status'].toString().toLowerCase() ==
                              _selectedFilter.toLowerCase(),
                        )
                        .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.marginMobile,
                  vertical: AppSizes.spacingLg,
                ),
                child: Column(
                  children: [
                    WithdrawalHistoryFilters(
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) =>
                          setState(() => _selectedFilter = filter),
                    ),
                    WithdrawalHistoryStats(
                      requests: allRequests,
                      user: userState.user,
                    ),
                    const SizedBox(height: AppSizes.spacingLg),
                    WithdrawalHistoryList(requests: filteredRequests),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
