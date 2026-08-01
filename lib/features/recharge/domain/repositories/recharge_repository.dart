abstract class RechargeRepository {
  /// Real-time stream of the user's recharge_balance field.
  Stream<double> watchRechargeBalance(String uid);

  /// Saves a pending manual recharge request to Firestore.
  Future<void> submitRechargeRequest({
    required String uid,
    required String userName,
    required String phone,
    required String operator,
    required String connectionType,
    required double amount,
  });

  /// Atomically moves [amount] from the user's main withdrawable balance
  /// (balance.earning + balance.referral + balance.voucher) into
  /// balance.recharge_balance using a Firestore WriteBatch.
  Future<void> transferFromMainWallet({
    required String uid,
    required double amount,
  });

  /// Real-time stream of the user's recharge request history.
  Stream<List<Map<String, dynamic>>> watchRechargeHistory(String uid);

  /// Saves a direct-deposit slip targeting the recharge wallet to Firestore.
  Future<void> submitRechargeDeposit({
    required String uid,
    required String userName,
    required String userEmail,
    required double amount,
    required String method,
    required String transactionId,
    required DateTime submittedAt,
  });
}
