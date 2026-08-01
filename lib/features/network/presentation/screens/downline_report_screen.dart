import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/network/domain/repositories/network_repository.dart';
import 'package:global_earn/features/network/presentation/bloc/downline_report_bloc.dart';
import 'package:global_earn/features/network/presentation/bloc/downline_report_event.dart';
import 'package:global_earn/features/network/presentation/bloc/downline_report_state.dart';
import 'package:global_earn/features/network/presentation/widgets/downline_report/downline_filter_tabs.dart';
import 'package:global_earn/features/network/presentation/widgets/downline_report/downline_search_field.dart';
import 'package:global_earn/features/network/presentation/widgets/downline_report/downline_summary_header.dart';
import 'package:global_earn/features/network/presentation/widgets/downline_report/downline_user_card.dart';
import 'package:global_earn/service_locator.dart';

class DownlineReportScreen extends StatelessWidget {
  final String referCode;

  const DownlineReportScreen({super.key, required this.referCode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DownlineReportBloc(networkRepository: sl<NetworkRepository>())
            ..add(LoadDownlines(referCode)),
      child: const _DownlineReportView(),
    );
  }
}

class _DownlineReportView extends StatelessWidget {
  const _DownlineReportView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'ডাউনলাইন রিপোর্ট',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<DownlineReportBloc, DownlineReportState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is DownlineLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is DownlineError) {
            return _ErrorView(message: state.message);
          }

          if (state is DownlineLoaded) {
            return Column(
              children: [
                DownlineSummaryHeader(
                  total: state.totalCount,
                  premium: state.premiumCount,
                  normal: state.normalCount,
                ),
                const DownlineFilterTabs(),
                const DownlineSearchField(),
                const SizedBox(height: 8),
                Expanded(child: _DownlineList(state: state)),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DownlineList extends StatelessWidget {
  final DownlineLoaded state;

  const _DownlineList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.filteredUsers.isEmpty) {
      return const Center(
        child: Text(
          'কোনো ডাউনলাইন নেই',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: state.filteredUsers.length,
      itemBuilder: (_, i) => DownlineUserCard(user: state.filteredUsers[i]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<DownlineReportBloc>().add(
              LoadDownlines(
                (context.read<DownlineReportBloc>().state is DownlineError)
                    ? ''
                    : '',
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('আবার চেষ্টা করুন'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
