abstract class DailyBonusRepository {
  /// Listen to today's daily bonus record for the current user
  Stream<Map<String, dynamic>?> streamDailyRecord(String date);

  /// Claim the daily bonus for today
  Future<void> claimDailyBonus(String date);

  /// Count verified (strict premium 320) Level 1 referrals
  /// that joined today (Bangladesh time UTC+6)
  Future<int> getTodayVerifiedCount(String referCode);
}
