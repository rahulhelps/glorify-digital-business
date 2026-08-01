import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_history_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_history_state.dart';

class TransactionHistoryList extends StatelessWidget {
  const TransactionHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    String currentUid = '';
    if (userState is UserLoaded) {
      currentUid = userState.user.uid;
    }

    return BlocBuilder<TransferHistoryBloc, TransferHistoryState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is! TransferHistoryLoaded) return const SizedBox();

        if (state.transfers.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                "???? ?????????? ???????? ???",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMd),
              child: Text(
                '?????????? ??????',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.transfers.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSizes.spacingSm),
              itemBuilder: (context, index) {
                final tx = state.transfers[index];
                final isInflow = tx['receiverUid'] == currentUid;
                final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
                final balance =
                    (tx['runningBalance'] as num?)?.toDouble() ?? 0.0;
                final createdAt = (tx['createdAt'] as Timestamp?)?.toDate();
                final dateStr = createdAt != null
                    ? DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt)
                    : 'N/A';

                final color = isInflow ? AppColors.success : AppColors.error;
                final title = isInflow
                    ? "??????? ?????????? ${tx['senderName'] ?? ''}"
                    : "??????? ?????????? ${tx['receiverName'] ?? ''}";

                return Container(
                  padding: const EdgeInsets.all(AppSizes.spacingMd),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                        ),
                        child: Icon(
                          isInflow ? Icons.arrow_downward : Icons.arrow_upward,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isInflow ? "+" : "-"}? ${amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                          Text(
                            'Bal: ? ${balance.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}


