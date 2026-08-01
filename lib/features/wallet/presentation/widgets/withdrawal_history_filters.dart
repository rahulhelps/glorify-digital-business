import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

class WithdrawalHistoryFilters extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const WithdrawalHistoryFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<String> _filters = const ['All', 'Pending', 'Success', 'Rejected'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingMd),
      child: Row(
        children: _filters.map((f) {
          final isSelected = selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.spacingSm),
            child: GestureDetector(
              onTap: () => onFilterChanged(f),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(
                    color: isSelected ? AppColors.secondary : AppColors.outline,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
