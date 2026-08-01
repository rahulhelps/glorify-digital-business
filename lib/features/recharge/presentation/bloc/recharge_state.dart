abstract class RechargeState {
  const RechargeState();
}

class RechargeInitial extends RechargeState {
  const RechargeInitial();
}

class RechargeLoading extends RechargeState {
  const RechargeLoading();
}

/// Emitted on every real-time balance update from Firestore.
class RechargeBalanceLoaded extends RechargeState {
  final double balance;
  const RechargeBalanceLoaded(this.balance);
}

class RechargeSubmitting extends RechargeState {
  const RechargeSubmitting();
}

class RechargeSubmitted extends RechargeState {
  final String successMessage;
  const RechargeSubmitted({this.successMessage = 'সফল হয়েছে!'});
}

class RechargeError extends RechargeState {
  final String message;
  const RechargeError(this.message);
}

class RechargeValidationError extends RechargeError {
  const RechargeValidationError(super.message);
}

class RechargeAmountCalculated extends RechargeState {
  final double amount;
  final double vatAmount;
  final double netAmount;

  const RechargeAmountCalculated(this.amount, this.vatAmount, this.netAmount);
}
