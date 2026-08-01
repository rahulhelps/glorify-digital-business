abstract class DepositRepository {
  Future<void> submitDeposit({
    required String uid,
    required String userName,
    required String userEmail,
    required double amount,
    required String method,
    required String transactionId,
    required DateTime submittedAt,
  });

  Stream<List<Map<String, dynamic>>> watchDepositHistory(String uid);

  Future<void> approveDeposit(String requestId, String uid, double amount);
}
