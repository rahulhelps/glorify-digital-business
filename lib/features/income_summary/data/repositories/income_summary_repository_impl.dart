import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/income_history_model.dart';
import '../../data/models/income_summary_model.dart';
import '../../domain/repositories/income_summary_repository.dart';

class IncomeSummaryRepositoryImpl implements IncomeSummaryRepository {
  final FirebaseFirestore _db;

  IncomeSummaryRepositoryImpl({required FirebaseFirestore db}) : _db = db;

  @override
  Future<IncomeSummaryModel> getIncomeSummary(String uid) async {
    try {
      dev.log('🔥 [IncomeSummary] Fetching for uid: $uid');

      final snapshot = await _db
          .collection('income_history')
          .where('uid', isEqualTo: uid)
          .get();

      final all = snapshot.docs
          .map((d) => IncomeHistoryModel.fromJson(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return IncomeSummaryModel(
        todayTotal: 0,
        weekTotal: 0,
        monthTotal: 0,
        byType: const {},
        byDay: const {},
        transactions: all,
      );
    } catch (e) {
      dev.log('❌ [IncomeSummary] getIncomeSummary error: $e');
      rethrow;
    }
  }

  @override
  List<IncomeHistoryModel> filterByDateRange({
    required List<IncomeHistoryModel> transactions,
    required DateTime from,
    required DateTime to,
  }) {
    return transactions
        .where(
          (t) =>
              !t.createdAt.isBefore(from) &&
              !t.createdAt.isAfter(to),
        )
        .toList();
  }
}
