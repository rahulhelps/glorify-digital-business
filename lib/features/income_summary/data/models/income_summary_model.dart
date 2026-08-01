import 'income_history_model.dart';

class IncomeSummaryModel {
  final double todayTotal;
  final double weekTotal;
  final double monthTotal;
  final Map<String, double> byType;

  /// Keys: 'YYYY-M-D' in BD timezone (UTC+6), last 7 days.
  final Map<String, double> byDay;
  final List<IncomeHistoryModel> transactions;

  const IncomeSummaryModel({
    required this.todayTotal,
    required this.weekTotal,
    required this.monthTotal,
    required this.byType,
    required this.byDay,
    required this.transactions,
  });

  static IncomeSummaryModel empty() => const IncomeSummaryModel(
    todayTotal: 0,
    weekTotal: 0,
    monthTotal: 0,
    byType: {},
    byDay: {},
    transactions: [],
  );
}
