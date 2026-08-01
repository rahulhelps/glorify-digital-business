import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/wallet/domain/repositories/withdraw_repository.dart';
import 'withdraw_history_event.dart';
import 'withdraw_history_state.dart';

class WithdrawHistoryBloc
    extends Bloc<WithdrawHistoryEvent, WithdrawHistoryState> {
  final WithdrawRepository repository;

  WithdrawHistoryBloc({required this.repository})
    : super(WithdrawHistoryInitial()) {
    on<LoadWithdrawHistory>((event, emit) async {
      emit(WithdrawHistoryLoading());
      await emit.forEach(
        repository.watchWithdrawHistory(event.uid),
        onData: (requests) => WithdrawHistoryLoaded(requests),
        onError: (e, stack) => WithdrawHistoryError(e.toString()),
      );
    });
  }
}
