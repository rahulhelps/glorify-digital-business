part of 'withdraw_bloc.dart';

abstract class WithdrawEvent {}

class SubmitWithdraw extends WithdrawEvent {
  final String method;
  final String accountNumber;
  final double amount;
  final String uid;
  final String userName;
  final double earning;
  final double voucher;
  final double referral;
  final String? bankName;

  SubmitWithdraw({
    required this.method,
    required this.accountNumber,
    required this.amount,
    required this.uid,
    required this.userName,
    required this.earning,
    required this.voucher,
    required this.referral,
    this.bankName,
  });
}

class SelectPaymentMethod extends WithdrawEvent {
  final String method;
  SelectPaymentMethod(this.method);
}

class UpdateBankName extends WithdrawEvent {
  final String bankName;
  UpdateBankName(this.bankName);
}

class AmountChangedEvent extends WithdrawEvent {
  final String amountStr;
  AmountChangedEvent(this.amountStr);
}
