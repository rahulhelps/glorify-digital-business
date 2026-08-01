import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/income_summary_repository.dart';
import '../../domain/entities/filter_type.dart';
import 'income_summary_event.dart';
import 'income_summary_state.dart';

class IncomeSummaryBloc extends Bloc<IncomeSummaryEvent, IncomeSummaryState> {
  final IncomeSummaryRepository _repository;
  final String _uid;

  IncomeSummaryBloc({
    required IncomeSummaryRepository repository,
    required String uid,
  }) : _repository = repository,
       _uid = uid,
       super(IncomeSummaryInitial()) {
    on<LoadIncomeDetail>(_onLoadDetail);
  }

  Future<void> _onLoadDetail(
    LoadIncomeDetail event,
    Emitter<IncomeSummaryState> emit,
  ) async {
    emit(IncomeSummaryLoading());
    try {
      dev.log('🔥 [IncomeSummaryBloc] Loading detail for uid: $_uid');
      final summary = await _repository.getIncomeSummary(_uid);
      
      final range = getDateRange(event.filterType);
      
      final filtered = _repository.filterByDateRange(
        transactions: summary.transactions,
        from: range.start,
        to: range.end,
      );
      
      final totalAmount = filtered.fold<double>(0, (sum, item) => sum + item.amount);

      emit(
        IncomeSummaryLoaded(
          transactions: filtered,
          totalAmount: totalAmount,
          filterType: event.filterType,
        ),
      );
    } catch (e) {
      debugPrint('❌ [IncomeSummaryBloc] Load error: $e');
      emit(const IncomeSummaryError('ইনকাম তথ্য লোড করতে সমস্যা হয়েছে'));
    }
  }

  DateTimeRange getDateRange(FilterType type) {
    final nowUtc = DateTime.now().toUtc();
    final nowBst = nowUtc.add(const Duration(hours: 6));
    
    // Start of today in BST, converted back to an absolute UTC moment
    final todayStartUtc = DateTime.utc(nowBst.year, nowBst.month, nowBst.day)
        .subtract(const Duration(hours: 6));

    // End of today in BST (11:59:59 PM)
    final todayEndUtc = todayStartUtc.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

    return switch (type) {
      FilterType.today => DateTimeRange(
          start: todayStartUtc,
          end: todayEndUtc,
        ),
      FilterType.yesterday => DateTimeRange(
          start: todayStartUtc.subtract(const Duration(days: 1)),
          end: todayStartUtc.subtract(const Duration(seconds: 1)),
        ),
      FilterType.sevenDays => DateTimeRange(
          start: todayStartUtc.subtract(const Duration(days: 6)),
          end: todayEndUtc,
        ),
      FilterType.thirtyDays => DateTimeRange(
          start: todayStartUtc.subtract(const Duration(days: 29)),
          end: todayEndUtc,
        ),
      FilterType.allTime => DateTimeRange(
          start: DateTime.utc(2020),
          end: todayEndUtc,
        ),
    };
  }
}
