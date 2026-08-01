import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/wallet/domain/repositories/transfer_repository.dart';
import 'transfer_history_event.dart';
import 'transfer_history_state.dart';

class TransferHistoryBloc
    extends Bloc<TransferHistoryEvent, TransferHistoryState> {
  final TransferRepository transferRepository;
  StreamSubscription? _subscription;
  List<Map<String, dynamic>> _allTransfers = [];
  DateTime _selectedMonth = DateTime.now();
  String? _uid;

  TransferHistoryBloc({required this.transferRepository})
    : super(TransferHistoryInitial()) {
    on<LoadTransferHistory>(_onLoadTransferHistory);
    on<FilterByMonth>(_onFilterByMonth);
    on<UpdateTransfers>(_onUpdateTransfers);
    on<HandleError>(_onHandleError);
  }

  void _onLoadTransferHistory(
    LoadTransferHistory event,
    Emitter<TransferHistoryState> emit,
  ) {
    _uid = event.uid;
    emit(TransferHistoryLoading());
    _subscription?.cancel();
    _subscription = transferRepository
        .watchTransferHistory(event.uid)
        .listen(
          (transfers) {
            add(UpdateTransfers(transfers));
          },
          onError: (error) {
            add(HandleError(error.toString()));
          },
        );
  }

  void _onFilterByMonth(
    FilterByMonth event,
    Emitter<TransferHistoryState> emit,
  ) {
    _selectedMonth = event.month;
    _emitLoaded(emit);
  }

  void _onUpdateTransfers(
    UpdateTransfers event,
    Emitter<TransferHistoryState> emit,
  ) {
    _allTransfers = event.transfers;
    _emitLoaded(emit);
  }

  void _onHandleError(HandleError event, Emitter<TransferHistoryState> emit) {
    emit(TransferHistoryError(event.message));
  }

  void _emitLoaded(Emitter<TransferHistoryState> emit) {
    // Calculate running balance based on ALL transfers (chronologically)
    final chronological = List<Map<String, dynamic>>.from(_allTransfers);
    chronological.sort((a, b) {
      final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
      final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
      return aTime.compareTo(bTime);
    });

    double currentBalance = 0;
    final Map<String, double> runningBalances = {};

    for (var t in chronological) {
      final amount = (t['amount'] as num?)?.toDouble() ?? 0;
      if (t['receiverUid'] == _uid) {
        currentBalance += amount;
      } else if (t['senderUid'] == _uid) {
        currentBalance -= amount;
      }
      runningBalances[t['id'] as String] = currentBalance;
    }

    final filtered = _allTransfers
        .where((t) {
          final date = (t['createdAt'] as Timestamp?)?.toDate();
          if (date == null) return false;
          return date.month == _selectedMonth.month &&
              date.year == _selectedMonth.year;
        })
        .map((t) {
          return {...t, 'runningBalance': runningBalances[t['id']]};
        })
        .toList();

    // Ensure filtered list is sorted newest first
    filtered.sort((a, b) {
      final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
      final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
      return bTime.compareTo(aTime);
    });

    double inflow = 0;
    double outflow = 0;

    for (var t in _allTransfers) {
      final amount = (t['amount'] as num?)?.toDouble() ?? 0;
      if (t['receiverUid'] == _uid) {
        inflow += amount;
      } else if (t['senderUid'] == _uid) {
        outflow += amount;
      }
    }

    emit(
      TransferHistoryLoaded(
        transfers: filtered,
        totalInflow: inflow,
        totalOutflow: outflow,
        selectedMonth: _selectedMonth,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
