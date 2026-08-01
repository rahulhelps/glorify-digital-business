abstract class RechargeEvent {
  const RechargeEvent();
}

class WatchRechargeBalance extends RechargeEvent {
  final String uid;
  const WatchRechargeBalance(this.uid);
}

class SubmitRechargeRequest extends RechargeEvent {
  final String uid;
  final String userName;
  final String phone;
  final String operator;
  final String connectionType;
  final double amount;

  const SubmitRechargeRequest({
    required this.uid,
    required this.userName,
    required this.phone,
    required this.operator,
    required this.connectionType,
    required this.amount,
  });
}

class TransferFromWallet extends RechargeEvent {
  final String uid;
  final double amount;
  final double currentMainBalance;

  const TransferFromWallet({
    required this.uid,
    required this.amount,
    required this.currentMainBalance,
  });
}


