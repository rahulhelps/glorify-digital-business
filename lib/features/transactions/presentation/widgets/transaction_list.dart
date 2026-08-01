import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/transactions/presentation/widgets/transaction_list_item.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        TransactionListItem(
          title: 'Fund Transfer',
          date: 'Oct 24, 2026 • 14:20',
          amount: '+৳ 4,500',
          status: 'Success',
          icon: Icons.south_west,
          color: AppColors.secondary,
        ),
        TransactionListItem(
          title: 'Withdraw',
          date: 'Oct 23, 2023 • 09:15',
          amount: '-৳ 2,000',
          status: 'Success',
          icon: Icons.north_east,
          color: AppColors.primary,
        ),
        TransactionListItem(
          title: 'Subscription',
          date: 'Oct 22, 2023 • 18:45',
          amount: '৳ 1,200',
          status: 'Pending',
          icon: Icons.schedule,
          color: AppColors.textSecondary,
          isPending: true,
        ),
        TransactionListItem(
          title: 'Cash In',
          date: 'Oct 21, 2023 • 11:30',
          amount: '+৳ 10,000',
          status: 'Success',
          icon: Icons.south_west,
          color: AppColors.secondary,
        ),
        TransactionListItem(
          title: 'Mobile Recharge',
          date: 'Oct 20, 2023 • 20:10',
          amount: '-৳ 500',
          status: 'Success',
          icon: Icons.north_east,
          color: AppColors.primary,
        ),
      ],
    );
  }
}
