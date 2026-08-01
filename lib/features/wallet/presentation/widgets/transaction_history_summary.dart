import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_history_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_history_state.dart';

class TransactionHistorySummary extends StatelessWidget {
  const TransactionHistorySummary({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransferHistoryBloc, TransferHistoryState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        double inflow = 0;
        double outflow = 0;

        if (state is TransferHistoryLoaded) {
          inflow = state.totalInflow;
          outflow = state.totalOutflow;
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSizes.spacingMd,
          mainAxisSpacing: AppSizes.spacingMd,
          childAspectRatio: 1.5,
          children: [
            _SummaryCard(
              label: 'TOTAL INFLOW',
              amount: '+? ${inflow.toStringAsFixed(0)}',
              accentColor: AppColors.success,
            ),
            _SummaryCard(
              label: 'TOTAL OUTFLOW',
              amount: '-? ${outflow.toStringAsFixed(0)}',
              accentColor: AppColors.error,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color accentColor;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

