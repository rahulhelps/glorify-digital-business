abstract class BonusRepository {
  /// Load bonus status from bonus_claims/{uid}/{bonusType}
  Future<Map<String, dynamic>> loadBonusStatus(String bonusType);

  /// Claim a bonus using a WriteBatch atomically
  Future<void> claimBonus({
    required String bonusType,
    required double amount,
    required String bonusName,
    Map<String, dynamic>? extraClaimData,
  });

  /// Update rankCount on the user document
  Future<void> updateRankCount(int rankCount);

  /// Count verified (strict premium 320) referrals at Level 1 and Level 2
  /// by querying Firestore directly — more reliable than user.team.level1Business
  Future<Map<String, int>> getVerifiedCounts(String referCode);

  /// Count verified referrals that joined today (Bangladesh time UTC+6)
  Future<int> getTodayVerifiedCount(String referCode);

  /// Count verified Level 1 referrals joined after the specified date for Lucky Start
  Future<int> getLuckyStartVerifiedCount(String referCode, DateTime? since);

  /// Load target bonus status (unlimited cycles)
  Future<Map<String, dynamic>> loadTargetBonusStatus();

  /// Claim target bonus cycles
  Future<void> claimTargetBonus({
    required int cyclesToClaim,
    required double amount,
  });

  /// Get verified count this week
  Future<int> getThisWeekVerifiedCount(String referCode);

  /// Load weekly bonus status
  Future<Map<String, dynamic>> loadWeeklyBonusStatus(String weekKey);

  /// Claim weekly bonus
  Future<void> claimWeeklyBonus({
    required String weekKey,
    required double amount,
    required int verifiedCount,
  });

  // ── Monthly Bonus ────────────────────────────────────────────────────────────

  /// Load the current 30-day cycle state from monthly_bonus_cycles/{uid}
  Future<Map<String, dynamic>> loadMonthlyBonusStatus();

  /// Count plan_320 referrals verified after the feature launch date AND
  /// within the active 30-day cycle window.
  Future<int> getMonthlyCycleVerifiedCount(String referCode);

  /// Credit ৳300 to wallet, mark cycle as claimed in Firestore, and log
  /// an income_history entry ("Monthly Bonus Reward - ৳300").
  Future<void> claimMonthlyBonus({
    required String cycleKey,
    required double amount,
    required int verifiedCount,
  });

  /// Reset the cycle: zero the verified count and set a fresh 30-day window.
  Future<void> resetMonthlyCycle(DateTime nowBst);

  // ── Yearly Bonus ─────────────────────────────────────────────────────────────
  
  Future<Map<String, dynamic>> loadYearlyBonusStatus();
  Future<int> getYearlyTeamCount(String referCode);
  Future<void> claimYearlyBonus({required int count});
}
