abstract class DepositState {}

class DepositInitial extends DepositState {}

class DepositLoading extends DepositState {}

class DepositSubmitting extends DepositState {}

class DepositSubmitted extends DepositState {}

class DepositHistoryLoaded extends DepositState {
  final List<Map<String, dynamic>> requests;
  final double totalDeposited;
  final int pendingCount;

  DepositHistoryLoaded({
    required this.requests,
    required this.totalDeposited,
    required this.pendingCount,
  });
}

class DepositError extends DepositState {
  final String message;

  DepositError(this.message);
}

class AutoDepositLoading extends DepositState {}

class AutoDepositUrlReady extends DepositState {
  final String paymentUrl;
  AutoDepositUrlReady(this.paymentUrl);
}

class AutoDepositError extends DepositState {
  final String message;
  AutoDepositError(this.message);
}
