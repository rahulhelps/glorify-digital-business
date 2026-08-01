import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WithdrawalHistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  const WithdrawalHistoryList({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              const Text(
                'কোনো উত্তোলনের ইতিহাস নেই',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spacingMd),
      itemBuilder: (context, index) {
        final request = requests[index];
        final method = request['method']?.toString().toLowerCase() ?? 'unknown';
        final status = request['status']?.toString().toLowerCase() ?? 'pending';
        final amount = (request['amount'] ?? 0.0).toDouble();
        final accountNumber = request['accountNumber']?.toString() ?? '';
        final bankName = request['bankName']?.toString();
        final requestedAt =
            (request['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final requestId = request['id']?.toString() ?? '';

        IconData icon;
        Color color;
        String title;

        switch (method) {
          case 'bkash':
          case 'nagad':
          case 'rocket':
            icon = Icons.smartphone;
            color = AppColors.primaryContainer;
            title =
                '${method[0].toUpperCase()}${method.substring(1)} Withdrawal';
            break;
          case 'bank':
            icon = Icons.account_balance;
            color = AppColors.secondary;
            title = bankName ?? 'Bank Transfer';
            break;
          default:
            icon = Icons.payments;
            color = AppColors.textSecondary;
            title = 'Withdrawal';
        }

        Color statusColor;
        String statusText;
        switch (status) {
          case 'pending':
            statusColor = Colors.orange;
            statusText = 'Pending';
            break;
          case 'approved':
          case 'success':
            statusColor = Colors.green;
            statusText = 'Success';
            break;
          case 'rejected':
            statusColor = Colors.red;
            statusText = 'Rejected';
            break;
          default:
            statusColor = AppColors.textSecondary;
            statusText = status.toUpperCase();
        }

        return _TransactionItem(
          title: title,
          date: DateFormat('dd MMM, yyyy • hh:mm a').format(requestedAt),
          txnId: 'TXN-${requestId.substring(0, 9).toUpperCase()}',
          amount: '-৳ ${amount.toStringAsFixed(0)}',
          status: statusText,
          statusColor: statusColor,
          icon: icon,
          iconBg: color,
          accountNumber: accountNumber,
        );
      },
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String txnId;
  final String amount;
  final String status;
  final Color statusColor;
  final IconData icon;
  final Color iconBg;
  final String accountNumber;

  const _TransactionItem({
    required this.title,
    required this.date,
    required this.txnId,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.iconBg,
    required this.accountNumber,
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              border: Border.all(color: iconBg.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: iconBg, size: 24),
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
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$accountNumber • $date',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  'ID: $txnId',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
