abstract class SubscriptionRepository {
  Future<void> savePaymentRequest({
    required String uid,
    required String userName,
    required String userEmail,
    required double amount,
    required String requestedPlan,
    required String method,
    required String transactionId,
    required DateTime submittedAt,
  });

  Future<String?> checkPendingRequest(String uid);

  Future<void> approveSubscription(String requestId, String uid);
}
