abstract class RechargeHistoryState {
  const RechargeHistoryState();
}

class RechargeHistoryInitial extends RechargeHistoryState {
  const RechargeHistoryInitial();
}

class RechargeHistoryLoading extends RechargeHistoryState {
  const RechargeHistoryLoading();
}

class RechargeHistoryLoaded extends RechargeHistoryState {
  final List<Map<String, dynamic>> requests;
  const RechargeHistoryLoaded(this.requests);
}

class RechargeHistoryError extends RechargeHistoryState {
  final String message;
  const RechargeHistoryError(this.message);
}