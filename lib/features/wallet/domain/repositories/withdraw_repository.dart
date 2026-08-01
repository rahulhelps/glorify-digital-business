abstract class WithdrawRepository {
  Future<void> submitWithdrawRequest({
    required String uid,
    required String userName,
    required double amount,
    required String method,
    required String accountNumber,
    required double earning,
    required double voucher,
    required double referral,
    String? bankName,
  });

  Stream<List<Map<String, dynamic>>> watchWithdrawHistory(String uid);
}
