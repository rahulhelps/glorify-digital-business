import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import '../../domain/entities/filter_type.dart';
import '../widgets/income_menu_card.dart';

class IncomeSummaryScreen extends StatelessWidget {
  const IncomeSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('ইনকাম সামারি', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            IncomeMenuCard(
              title: 'আজকের ইনকাম',
              subtitle: 'আজকের মোট আয় দেখুন',
              emoji: '📅',
              onTap: () => context.push('/income-summary/detail', extra: FilterType.today),
            ),
            IncomeMenuCard(
              title: 'গতকালের ইনকাম',
              subtitle: 'গতকালের মোট আয় দেখুন',
              emoji: '📆',
              onTap: () => context.push('/income-summary/detail', extra: FilterType.yesterday),
            ),
            IncomeMenuCard(
              title: '৭ দিনের ইনকাম',
              subtitle: 'গত ৭ দিনের আয় দেখুন',
              emoji: '📊',
              onTap: () => context.push('/income-summary/detail', extra: FilterType.sevenDays),
            ),
            IncomeMenuCard(
              title: '৩০ দিনের ইনকাম',
              subtitle: 'গত ৩০ দিনের আয় দেখুন',
              emoji: '🗓️',
              onTap: () => context.push('/income-summary/detail', extra: FilterType.thirtyDays),
            ),
            IncomeMenuCard(
              title: 'সর্বমোট ইনকাম',
              subtitle: 'এখন পর্যন্ত মোট আয়',
              emoji: '💰',
              onTap: () => context.push('/income-summary/detail', extra: FilterType.allTime),
            ),
          ],
        ),
      ),
    );
  }
}
