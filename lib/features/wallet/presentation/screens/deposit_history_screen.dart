import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/wallet/presentation/bloc/deposit_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/deposit_event.dart';
import 'package:global_earn/features/wallet/presentation/bloc/deposit_state.dart';
import 'package:global_earn/service_locator.dart';

class DepositHistoryScreen extends StatelessWidget {
  const DepositHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    if (userState is! UserLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final uid = userState.user.uid;

    return BlocProvider(
      create: (context) => sl<DepositBloc>()..add(LoadDepositHistory(uid)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            '??????? ????????',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<DepositBloc, DepositState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state is DepositLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DepositError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            } else if (state is DepositHistoryLoaded) {
              final requests = state.requests;
              return Column(
                children: [
                  // Summary Cards
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            '??? ???????',
                            '? ${state.totalDeposited.toStringAsFixed(2)}',
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            '?????????',
                            '${state.pendingCount} ??',
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List
                  Expanded(
                    child: requests.isEmpty
                        ? const Center(
                            child: Text(
                              '???? ??????? ???????? ???',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: requests.length,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemBuilder: (context, index) {
                              final req = requests[index];
                              return _buildHistoryCard(req);
                            },
                          ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> req) {
    final status = req['status'] as String? ?? 'pending';
    final amount = req['amount']?.toDouble() ?? 0.0;
    final method = req['method'] as String? ?? 'Unknown';
    final transactionId = req['transactionId'] as String? ?? '';

    // Parse time
    final submittedAtRaw = req['submittedAt'];
    DateTime date = DateTime.now();
    if (submittedAtRaw != null) {
      if (submittedAtRaw is int) {
        date = DateTime.fromMillisecondsSinceEpoch(submittedAtRaw);
      } else if (submittedAtRaw is Timestamp) {
        try {
          date = submittedAtRaw.toDate();
        } catch (_) {}
      }
    }
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

    Color statusColor;
    String statusText;
    if (status == 'approved') {
      statusColor = Colors.green;
      statusText = '????????';
    } else if (status == 'rejected') {
      statusColor = Colors.red;
      statusText = '????????????';
    } else {
      statusColor = Colors.orange;
      statusText = '?????????';
    }

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          transactionId,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '+?$amount',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.outline),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

