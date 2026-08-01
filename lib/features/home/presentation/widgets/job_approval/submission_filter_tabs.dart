import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/data/models/submission_model.dart';

/// Filter tab row: All / Pending / Approved / Rejected
class SubmissionFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final List<SubmissionModel> allSubmissions;
  final ValueChanged<String> onFilterChanged;

  const SubmissionFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.allSubmissions,
    required this.onFilterChanged,
  });

  int _count(String filter) {
    if (filter == 'all') return allSubmissions.length;
    return allSubmissions.where((s) => s.status == filter).length;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('all', 'সব'),
      ('pending', 'অপেক্ষমাণ'),
      ('approved', 'অনুমোদিত'),
      ('rejected', 'প্রত্যাখ্যাত'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline, width: 1)),
      ),
      child: Row(
        children: tabs.map((tab) {
          final key = tab.$1;
          final label = tab.$2;
          final isSelected = selectedFilter == key;
          final count = _count(key);
          return Expanded(
            child: InkWell(
              onTap: () => onFilterChanged(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (count > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceDim,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
