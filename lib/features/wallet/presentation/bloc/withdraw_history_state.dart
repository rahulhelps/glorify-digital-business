abstract class WithdrawHistoryState {}

class WithdrawHistoryInitial extends WithdrawHistoryState {}

class WithdrawHistoryLoading extends WithdrawHistoryState {}

class WithdrawHistoryLoaded extends WithdrawHistoryState {
  final List<Map<String, dynamic>> requests;
  WithdrawHistoryLoaded(this.requests);
}

class WithdrawHistoryError extends WithdrawHistoryState {
  final String message;
  WithdrawHistoryError(this.message);
}
