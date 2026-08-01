class AppConstants {

  static const String defaultReferCode = '123456';

  static const Map<int, double> referralBonusMap = {

    1: 75,
    2: 35,
    3: 15,
    4: 10,
    5: 5,
    6: 4,
    7: 3,
    8: 3,
    9: 2,
    10: 2,
  };

  static const paymentNumber = "";
  static const bkashNumber = "";
  static const nagadNumber = "";
  static const rocketNumber = "";
  static const supportEmail = '';
  static const supportPhone = '';
}

class SubscriptionStatus {
  static const none    = 'none';     // unverified user
  static const pending = 'pending';  // payment submitted, in review

  // New plan values
  static const plan320      = 'plan_320'; // full premium (৳320 plan)
  static const plan320Short = '320';      // short alias stored by some admin flows

  /// All status values that count as "verified" (any tier).
  static const List<String> activeStatuses = [
    plan320, plan320Short,
  ];

  /// Premium status values
  static const List<String> premiumStatuses = [
    plan320, plan320Short,
  ];

  /// Strict 320 TK Premium status values ONLY.
  static const List<String> strictPremium320Statuses = [
    plan320, plan320Short,
  ];
}

