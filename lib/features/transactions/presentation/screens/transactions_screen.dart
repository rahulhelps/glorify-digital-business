import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:global_earn/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:global_earn/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:global_earn/features/transactions/presentation/widgets/transaction_list.dart';
import 'package:global_earn/features/transactions/presentation/widgets/transactions_filter_row.dart';
import 'package:global_earn/features/transactions/presentation/widgets/transactions_hero_card.dart';
import 'package:global_earn/features/transactions/presentation/widgets/transactions_summary_widget.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionsBloc>().add(LoadTransactions());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is! TransactionsLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppSizes.marginMobile,
            right: AppSizes.marginMobile,
            bottom: 96,
            top: AppSizes.spacingMd,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TransactionsHeroCard(),
              SizedBox(height: AppSizes.spacingLg),
              TransactionsFilterRow(),
              SizedBox(height: AppSizes.spacingLg),
              TransactionList(),
              SizedBox(height: AppSizes.spacingLg),
              TransactionsSummaryWidget(),
            ],
          ),
        );
      },
    );
  }
}
