import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_history_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_history_event.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_history_state.dart';

class TransactionHistoryFilters extends StatelessWidget {
  const TransactionHistoryFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransferHistoryBloc, TransferHistoryState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        DateTime selectedMonth = DateTime.now();
        if (state is TransferHistoryLoaded) {
          selectedMonth = state.selectedMonth;
        }

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedMonth,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2101),
                    helpText: 'Select Month',
                  );
                  if (picked != null && context.mounted) {
                    context.read<TransferHistoryBloc>().add(
                      FilterByMonth(picked),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingMd,
                    vertical: AppSizes.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSizes.spacingXs),
                          Text(
                            DateFormat('MMMM yyyy').format(selectedMonth),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacingMd),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.outline),
              ),
              child: IconButton(
                onPressed: () {
                  // Reset to current month
                  context.read<TransferHistoryBloc>().add(
                    FilterByMonth(DateTime.now()),
                  );
                },
                icon: const Icon(Icons.refresh, color: AppColors.secondary),
              ),
            ),
          ],
        );
      },
    );
  }
}
