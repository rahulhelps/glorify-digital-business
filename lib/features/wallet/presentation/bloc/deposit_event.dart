abstract class DepositEvent {}

class SubmitDeposit extends DepositEvent {
  final double amount;
  final String method;
  final String transactionId;
  final DateTime submittedAt;
  final String uid;
  final String userName;
  final String userEmail;

  SubmitDeposit({
    required this.amount,
    required this.method,
    required this.transactionId,
    required this.submittedAt,
    required this.uid,
    required this.userName,
    required this.userEmail,
  });
}

class LoadDepositHistory extends DepositEvent {
  final String uid;

  LoadDepositHistory(this.uid);
}

class AutoDepositRequested extends DepositEvent {
  final String uid;
  final double amount;
  AutoDepositRequested({required this.uid, required this.amount});
}
