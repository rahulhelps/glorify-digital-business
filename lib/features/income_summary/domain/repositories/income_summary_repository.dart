import '../../data/models/income_summary_model.dart';
import '../../data/models/income_history_model.dart';

abstract class IncomeSummaryRepository {
  Future<IncomeSummaryModel> getIncomeSummary(String uid);

  /// Returns transactions filtered between [from] and [to] (inclusive).
  List<IncomeHistoryModel> filterByDateRange({
    required List<IncomeHistoryModel> transactions,
    required DateTime from,
    required DateTime to,
  });
}
