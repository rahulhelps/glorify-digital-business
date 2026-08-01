abstract class WithdrawHistoryEvent {}

class LoadWithdrawHistory extends WithdrawHistoryEvent {
  final String uid;
  LoadWithdrawHistory(this.uid);
}
