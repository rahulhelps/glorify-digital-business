import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/recharge/domain/repositories/recharge_repository.dart';
import 'recharge_history_event.dart';
import 'recharge_history_state.dart';

class RechargeHistoryBloc
    extends Bloc<RechargeHistoryEvent, RechargeHistoryState> {
  final RechargeRepository repository;

  RechargeHistoryBloc({required this.repository})
      : super(const RechargeHistoryInitial()) {
    on<WatchRechargeHistory>(_onWatchHistory);
  }

  Future<void> _onWatchHistory(
    WatchRechargeHistory event,
    Emitter<RechargeHistoryState> emit,
  ) async {
    emit(const RechargeHistoryLoading());
    await emit.forEach<List<Map<String, dynamic>>>(
      repository.watchRechargeHistory(event.uid),
      onData: (requests) => RechargeHistoryLoaded(requests),
      onError: (e, _) {
        dev.log('[RechargeHistoryBloc] Stream error: $e');
        return RechargeHistoryError(e.toString());
      },
    );
  }
}