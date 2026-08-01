part of 'withdraw_bloc.dart';

abstract class WithdrawState {
  final String? bankName;
  final String? selectedMethod;
  final double inputAmount;
  final double feeAmount;
  final double payableAmount;

  WithdrawState({
    this.bankName,
    this.selectedMethod,
    this.inputAmount = 0.0,
    this.feeAmount = 0.0,
    this.payableAmount = 0.0,
  });
}

class WithdrawInitial extends WithdrawState {
  WithdrawInitial({
    super.bankName,
    super.selectedMethod,
    super.inputAmount,
    super.feeAmount,
    super.payableAmount,
  });
}

class WithdrawLoading extends WithdrawState {
  WithdrawLoading({
    super.bankName,
    super.selectedMethod,
    super.inputAmount,
    super.feeAmount,
    super.payableAmount,
  });
}

class WithdrawSuccess extends WithdrawState {
  WithdrawSuccess({
    super.bankName,
    super.selectedMethod,
    super.inputAmount,
    super.feeAmount,
    super.payableAmount,
  });
}

class WithdrawError extends WithdrawState {
  final String message;
  WithdrawError(
    this.message, {
    super.bankName,
    super.selectedMethod,
    super.inputAmount,
    super.feeAmount,
    super.payableAmount,
  });
}
