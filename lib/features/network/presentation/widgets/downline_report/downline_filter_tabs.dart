import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/network/presentation/bloc/downline_report_bloc.dart';
import 'package:global_earn/features/network/presentation/bloc/downline_report_event.dart';
import 'package:global_earn/features/network/presentation/bloc/downline_report_state.dart';

class DownlineFilterTabs extends StatelessWidget {
  const DownlineFilterTabs({super.key});

  static const _tabs = [
    ('all', 'সব'),
    ('premium', 'প্রিমিয়াম'),
    ('normal', 'সাধারণ'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownlineReportBloc, DownlineReportState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        final activeFilter = state is DownlineLoaded
            ? state.activeFilter
            : 'all';

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.marginMobile,
            vertical: AppSizes.spacingMd,
          ),
          child: Row(
            children: _tabs.map((tab) {
              final isActive = activeFilter == tab.$1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: InkWell(
                      onTap: () => context.read<DownlineReportBloc>().add(
                        FilterDownlines(tab.$1),
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull,
                          ),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.outline,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tab.$2,
                          style: TextStyle(
                            color: isActive
                                ? AppColors.white
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
