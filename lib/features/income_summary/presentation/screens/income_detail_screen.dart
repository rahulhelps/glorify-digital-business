import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import '../../domain/entities/filter_type.dart';
import '../bloc/income_summary_bloc.dart';
import '../bloc/income_summary_event.dart';
import '../bloc/income_summary_state.dart';
import '../widgets/income_top_card.dart';
import 'income_history_list_screen.dart';

class IncomeDetailScreen extends StatefulWidget {
  final FilterType filterType;

  const IncomeDetailScreen({super.key, required this.filterType});

  @override
  State<IncomeDetailScreen> createState() => _IncomeDetailScreenState();
}

class _IncomeDetailScreenState extends State<IncomeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<IncomeSummaryBloc>().add(LoadIncomeDetail(widget.filterType));
      }
    });
  }

  String get _title => switch (widget.filterType) {
        FilterType.today => 'আজকের ইনকাম',
        FilterType.yesterday => 'গতকালের ইনকাম',
        FilterType.sevenDays => '৭ দিনের ইনকাম',
        FilterType.thirtyDays => '৩০ দিনের ইনকাম',
        FilterType.allTime => 'সর্বমোট ইনকাম',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(_title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<IncomeSummaryBloc>(),
                    child: const IncomeHistoryListScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<IncomeSummaryBloc, IncomeSummaryState>(
        builder: (context, state) {
          if (state is IncomeSummaryLoading || state is IncomeSummaryInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is IncomeSummaryError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          } else if (state is IncomeSummaryLoaded) {
            final dateRange = context.read<IncomeSummaryBloc>().getDateRange(widget.filterType);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: IncomeTopCard(
                      filterType: widget.filterType,
                      amount: state.totalAmount,
                      dateRange: dateRange,
                    ),
                  ),
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
