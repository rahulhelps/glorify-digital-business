abstract class RechargeHistoryEvent {
  const RechargeHistoryEvent();
}

class WatchRechargeHistory extends RechargeHistoryEvent {
  final String uid;
  const WatchRechargeHistory(this.uid);
}