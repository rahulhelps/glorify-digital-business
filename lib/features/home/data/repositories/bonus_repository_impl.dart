import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:global_earn/core/constants/app_constants.dart';
import 'package:global_earn/core/utils/time_utils.dart';
import '../../domain/repositories/bonus_repository.dart';

class BonusRepositoryImpl implements BonusRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  BonusRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _db = firestore,
       _auth = auth;

  String get _uid => _auth.currentUser?.uid ?? '';

  @override
  Future<Map<String, dynamic>> loadBonusStatus(String bonusType) async {
    debugPrint('🔥 [Bonus] Loading status for: $bonusType');
    final uid = _uid;
    if (uid.isEmpty) throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');

    // Load user doc and claim doc concurrently
    final results = await Future.wait([
      _db.collection('users').doc(uid).get(),
      _db
          .collection('bonus_claims')
          .doc(uid)
          .collection(bonusType)
          .doc('data')
          .get(),
    ]);

    final userDoc = results[0];
    final claimDoc = results[1];

    final userData = userDoc.data() ?? {};
    final rankCount = (userData['rankCount'] ?? 0) as int;
    final referCode = userData['referCode'] as String? ?? '';
    final lastLuckyClaimAt = (userData['lastLuckyClaimAt'] as Timestamp?)?.toDate();
    final lastTeamClaimAt = (userData['lastTeamClaimAt'] as Timestamp?)?.toDate();

    final claimData = claimDoc.exists
        ? claimDoc.data() ?? {}
        : <String, dynamic>{};

    // Get real verified counts directly from Firestore
    // This is more reliable than user.team.level1Business which may not be updated
    int l1 = 0, l2 = 0;
    if (referCode.isNotEmpty) {
      if (bonusType == 'lucky_start_bonus') {
        l1 = await getLuckyStartVerifiedCount(referCode, lastLuckyClaimAt);
      } else {
        final counts = await getVerifiedCounts(referCode);
        l1 = counts['level1'] ?? 0;
        l2 = counts['level2'] ?? 0;
      }
    }

    int currentVerifiedCount = 0;
    if (bonusType == 'team_bonus_program' && referCode.isNotEmpty) {
      currentVerifiedCount = await getLuckyStartVerifiedCount(referCode, lastTeamClaimAt);
    }

    return {
      'level1Verified': l1,
      'level2Verified': l2,
      'rankCount': rankCount,
      'status': claimData['status'] ?? 'pending',
      'bonusClaimed': claimData['bonusClaimed'] ?? false,
      'claimedAt': claimData['claimedAt'],
      'level1Count': claimData['level1Count'] ?? l1,
      'level2Count': claimData['level2Count'] ?? l2,
      'claimedCount': claimData['claimedCount'] ?? 0,
      if (bonusType == 'team_bonus_program')
        'currentVerifiedCount': currentVerifiedCount,
    };
  }

  @override
  Future<void> claimBonus({
    required String bonusType,
    required double amount,
    required String bonusName,
    Map<String, dynamic>? extraClaimData,
  }) async {
    try {
      debugPrint('🔥 [$bonusName] Starting claim for uid: $_uid');
      debugPrint('🔥 [$bonusName] Amount: ৳$amount');
      final uid = _uid;
      if (uid.isEmpty) throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');

      if (bonusType == 'team_bonus_program') {
        final userDocBefore = await _db.collection('users').doc(uid).get();
        final userDataBefore = userDocBefore.data() ?? {};
        final referCodeBefore = userDataBefore['referCode'] as String? ?? '';
        final lastTeamClaimAtBefore = (userDataBefore['lastTeamClaimAt'] as Timestamp?)?.toDate();

        int liveCount = 0;
        if (referCodeBefore.isNotEmpty) {
          liveCount = await getLuckyStartVerifiedCount(referCodeBefore, lastTeamClaimAtBefore);
        }

        await _db.runTransaction((transaction) async {
          final userRef = _db.collection('users').doc(uid);
          final userSnapshot = await transaction.get(userRef);

          if (!userSnapshot.exists) {
            throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');
          }

          if (liveCount < 50) {
            throw Exception('not eligible - requirements not met');
          }

          transaction.update(userRef, {
            'balance.earning': FieldValue.increment(amount),
            'balance.total': FieldValue.increment(amount),
            'lastTeamClaimAt': FieldValue.serverTimestamp(),
            'total_team_bonuses_earned': FieldValue.increment(1),
          });

          final historyRef = _db.collection('income_history').doc();
          transaction.set(historyRef, {
            'uid': uid,
            'amount': amount,
            'type': 'team_bonus',
            'description': 'Team Bonus',
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
        debugPrint('✅ [Team Bonus] Transaction committed');
        return;
      }

      if (bonusType == 'leadership_bonus') {
        final userDocBefore = await _db.collection('users').doc(uid).get();
        final userDataBefore = userDocBefore.data() ?? {};
        final referCodeBefore = userDataBefore['referCode'] as String? ?? '';

        if (referCodeBefore.isEmpty) {
          throw Exception('Not eligible - No refer code');
        }

        // Query potential referrals outside the transaction to get DocumentReferences
        final level1Query = await _db
            .collection('users')
            .where('referredBy', isEqualTo: referCodeBefore)
            .where('subscriptionStatus', whereIn: SubscriptionStatus.strictPremium320Statuses)
            .get();

        final potentialRefs = <DocumentReference>[];
        for (var doc in level1Query.docs) {
          final data = doc.data();
          if (data['isLeadershipClaimed'] != true) {
            potentialRefs.add(doc.reference);
          }
        }

        if (potentialRefs.length < 15) {
          throw Exception('not eligible - requirements not met');
        }

        // Take exactly 15 eligible referral documents
        final refsToClaim = potentialRefs.take(15).toList();

        await _db.runTransaction((transaction) async {
          // 1. Read the user doc to lock it
          final userRef = _db.collection('users').doc(uid);
          final userSnapshot = await transaction.get(userRef);

          if (!userSnapshot.exists) {
            throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');
          }

          // 2. Read and lock all 15 referral documents
          for (var ref in refsToClaim) {
            final docSnap = await transaction.get(ref);
            if (!docSnap.exists) {
              throw Exception('Referral no longer exists');
            }
            final data = docSnap.data() as Map<String, dynamic>? ?? {};
            if (data['isLeadershipClaimed'] == true) {
              throw Exception('Race condition detected: Referral already claimed');
            }
          }

          // 3. Write: Update user balance
          transaction.update(userRef, {
            'balance.earning': FieldValue.increment(amount),
            'balance.total': FieldValue.increment(amount),
          });

          // 4. Write: Mark all 15 referrals as claimed
          for (var ref in refsToClaim) {
            transaction.update(ref, {
              'isLeadershipClaimed': true,
            });
          }

          // 5. Write: Update claimedCount on the user's bonus doc (for UI consistency)
          final claimRef = _db
              .collection('bonus_claims')
              .doc(uid)
              .collection(bonusType)
              .doc('data');
          
          transaction.set(claimRef, {
            'claimedCount': FieldValue.increment(1),
            'lastClaimedAt': FieldValue.serverTimestamp(),
            ...?extraClaimData,
          }, SetOptions(merge: true));

          // 6. Write: Add income history
          final historyRef = _db.collection('income_history').doc();
          transaction.set(historyRef, {
            'uid': uid,
            'amount': amount,
            'type': 'leadership_bonus',
            'description': 'Leadership বোনাস',
            'createdAt': FieldValue.serverTimestamp(),
          });
        });

        debugPrint('✅ [Leadership Bonus] Transaction committed — 15 referrals marked and balance updated');
        return;
      }

      final userDoc = await _db.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};
      final referCode = userData['referCode'] as String? ?? '';
      final lastLuckyClaimAt = (userData['lastLuckyClaimAt'] as Timestamp?)?.toDate();

      int l1 = 0, l2 = 0;
      if (referCode.isNotEmpty) {
        if (bonusType == 'lucky_start_bonus') {
          l1 = await getLuckyStartVerifiedCount(referCode, lastLuckyClaimAt);
        } else {
          final counts = await getVerifiedCounts(referCode);
          l1 = counts['level1'] ?? 0;
          l2 = counts['level2'] ?? 0;
        }
      }

      final claimRef = _db
          .collection('bonus_claims')
          .doc(uid)
          .collection(bonusType)
          .doc('data');
      final claimDoc = await claimRef.get();
      final claimData = claimDoc.exists
          ? claimDoc.data() ?? {}
          : <String, dynamic>{};

      if (bonusType != 'leadership_bonus' &&
          bonusType != 'lucky_start_bonus' &&
          (claimData['bonusClaimed'] == true ||
              claimData['status'] == 'claimed')) {
        throw Exception('এই বোনাস ইতোমধ্যে নেওয়া হয়েছে');
      }

      switch (bonusType) {
        case 'lucky_start_bonus':
          if (l1 < 20) {
            throw Exception('not eligible - requirements not met');
          }
          break;
        case 'welcome_bonus': // legacy key — keep for backward compat
          if (l1 < 10 || l2 < 10) {
            throw Exception('not eligible - requirements not met');
          }
          break;
        case 'team_bonus':
          if (l1 < 20 || l2 < 40) {
            throw Exception('not eligible - requirements not met');
          }
          break;
      }

      final batch = _db.batch();

      // Add to user balance
      batch.update(_db.collection('users').doc(uid), {
        'balance.earning': FieldValue.increment(amount),
        'balance.total': FieldValue.increment(amount),
        if (bonusType == 'lucky_start_bonus') 'lastLuckyClaimAt': FieldValue.serverTimestamp(),
      });

      // Mark as claimed
      if (bonusType == 'lucky_start_bonus') {
        batch.set(claimRef, {
          'claimedCount': FieldValue.increment(1),
          'lastClaimedAt': FieldValue.serverTimestamp(),
          ...?extraClaimData,
        }, SetOptions(merge: true));
      } else {
        batch.set(claimRef, {
          'bonusClaimed': true,
          'status': 'claimed', // For backwards compatibility
          'claimedAt': FieldValue.serverTimestamp(),
          ...?extraClaimData,
        }, SetOptions(merge: true));
      }

      // Add income history
      final historyRef = _db.collection('income_history').doc();
      batch.set(historyRef, {
        'uid': uid,
        'amount': amount,
        'type': bonusType,
        'description': bonusType == 'lucky_start_bonus'
            ? 'Lucky Start Bonus'
            : '$bonusName বোনাস',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      debugPrint('✅ [$bonusName] Batch committed — balance updated');
    } catch (e) {
      debugPrint('❌ [$bonusName] Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateRankCount(int rankCount) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).update({'rankCount': rankCount});
  }

  @override
  Future<Map<String, int>> getVerifiedCounts(String referCode) async {
    debugPrint('🔥 [Bonus] Getting verified counts for: $referCode');

    // Level 1: users directly referred by current user with strict premium 320 status
    final level1Query = await _db
        .collection('users')
        .where('referredBy', isEqualTo: referCode)
        .where('subscriptionStatus', whereIn: SubscriptionStatus.strictPremium320Statuses)
        .get();
    final level1Count = level1Query.docs.length;

    // Collect referCodes of level 1 users to query level 2
    final level1Codes = level1Query.docs
        .map((d) => d.data()['referCode'] as String? ?? '')
        .where((c) => c.isNotEmpty)
        .toList();

    // Level 2: users referred by any level 1 user with strict premium 320 status
    final List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [];
    // Query in batches of 10 (Firestore combined whereIn limit is 30)
    for (int i = 0; i < level1Codes.length; i += 10) {
      final batch = level1Codes.sublist(i, min(i + 10, level1Codes.length));
      final future = _db
          .collection('users')
          .where('referredBy', whereIn: batch)
          .where('subscriptionStatus', whereIn: SubscriptionStatus.strictPremium320Statuses)
          .get();
      futures.add(future);
    }

    final results = await Future.wait(futures);
    int level2Count = 0;
    for (final query in results) {
      level2Count += query.docs.length;
    }

    debugPrint('✅ [Bonus] Level 1 verified: $level1Count');
    debugPrint('✅ [Bonus] Level 2 verified: $level2Count');

    return {'level1': level1Count, 'level2': level2Count};
  }

  @override
  Future<int> getTodayVerifiedCount(String referCode) async {
    // Fetch network time and query users concurrently
    final results = await Future.wait([
      TimeUtils.getNetworkUtcTime(),
      _db
          .collection('users')
          .where('referredBy', isEqualTo: referCode)
          .where('subscriptionStatus', whereIn: SubscriptionStatus.strictPremium320Statuses)
          .get(),
    ]);

    final DateTime networkUtc = results[0] as DateTime;
    final QuerySnapshot<Map<String, dynamic>> query =
        results[1] as QuerySnapshot<Map<String, dynamic>>;

    final nowBst = networkUtc.add(const Duration(hours: 6));

    // Start of today in Bangladesh time, converted back to UTC for Firestore
    final todayStartBst = DateTime(nowBst.year, nowBst.month, nowBst.day);
    final todayStartUtc = todayStartBst.subtract(const Duration(hours: 6)).toUtc();

    debugPrint(
      '🔥 [DailyBonus] Getting today verified count for: $referCode (since $todayStartUtc UTC)',
    );

    final todayVerified = query.docs.where((doc) {
      final joinedAt = (doc.data()['joinedAt'] as Timestamp?)?.toDate();
      return joinedAt != null && joinedAt.isAfter(todayStartUtc);
    }).length;

    debugPrint('✅ [DailyBonus] Today verified: $todayVerified');
    return todayVerified;
  }

  @override
  Future<int> getLuckyStartVerifiedCount(String referCode, DateTime? since) async {
    debugPrint(
      '🔥 [LuckyStart] Getting verified count for: $referCode (since ${since?.toUtc() ?? 'beginning of time'} UTC)',
    );

    // Fetch network time and query users concurrently
    final results = await Future.wait([
      TimeUtils.getNetworkUtcTime(),
      _db
          .collection('users')
          .where('referredBy', isEqualTo: referCode)
          .where('subscriptionStatus', whereIn: SubscriptionStatus.strictPremium320Statuses)
          .get(),
    ]);

    final QuerySnapshot<Map<String, dynamic>> query =
        results[1] as QuerySnapshot<Map<String, dynamic>>;

    final count = query.docs.where((doc) {
      if (since == null) return true;
      
      final data = doc.data();
      final joinedAt = (data['joinedAt'] as Timestamp?)?.toDate();
      final verifiedAt = (data['verifiedAt'] as Timestamp?)?.toDate();
      
      final isJoinedAfter = joinedAt != null && joinedAt.isAfter(since);
      final isVerifiedAfter = verifiedAt != null && verifiedAt.isAfter(since);
      
      return isJoinedAfter || isVerifiedAfter;
    }).length;

    debugPrint('✅ [LuckyStart] Verified since last claim: $count');
    return count;
  }

  @override
  Future<Map<String, dynamic>> loadTargetBonusStatus() async {
    debugPrint('🔥 [TargetBonus] Loading target bonus status');
    final uid = _uid;
    if (uid.isEmpty) throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');

    final userDoc = await _db.collection('users').doc(uid).get();
    final userData = userDoc.data() ?? {};
    final referCode = userData['referCode'] as String? ?? '';

    // Run getVerifiedCounts and target_bonus_claims fetch concurrently
    final Future<Map<String, int>?> countsFuture = referCode.isNotEmpty
        ? getVerifiedCounts(referCode)
        : Future.value(null);

    final results = await Future.wait([
      countsFuture,
      _db.collection('target_bonus_claims').doc(uid).get(),
    ]);

    final counts = results[0] as Map<String, int>?;
    final claimDoc = results[1] as DocumentSnapshot<Map<String, dynamic>>;

    final l1 = counts?['level1'] ?? 0;

    final claimData = claimDoc.exists
        ? claimDoc.data() ?? {}
        : <String, dynamic>{};

    final totalCyclesClaimed = (claimData['totalCyclesClaimed'] ?? 0) as int;
    final totalEarned = (claimData['totalEarned'] ?? 0).toDouble();

    return {
      'level1Verified': l1,
      'totalCyclesClaimed': totalCyclesClaimed,
      'totalEarned': totalEarned,
      'lastClaimedAt': claimData['lastClaimedAt'],
    };
  }

  @override
  Future<void> claimTargetBonus({
    required int cyclesToClaim,
    required double amount,
  }) async {
    try {
      debugPrint('🔥 [TargetBonus] Starting claim for uid: $_uid');
      debugPrint('🔥 [TargetBonus] Amount: ৳$amount');
      final uid = _uid;
      if (uid.isEmpty) throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');

      if (cyclesToClaim <= 0) {
        throw Exception('এই বোনাস ইতোমধ্যে নেওয়া হয়েছে');
      }

      final claimRef = _db.collection('target_bonus_claims').doc(uid);
      final batch = _db.batch();

      // Add to user balance
      batch.update(_db.collection('users').doc(uid), {
        'balance.earning': FieldValue.increment(amount),
        'balance.total': FieldValue.increment(amount),
      });

      // Mark as claimed (incremental)
      batch.set(claimRef, {
        'totalCyclesClaimed': FieldValue.increment(cyclesToClaim),
        'totalEarned': FieldValue.increment(amount),
        'lastClaimedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add income history
      final historyRef = _db.collection('income_history').doc();
      batch.set(historyRef, {
        'uid': uid,
        'amount': amount,
        'type': 'target_bonus',
        'description': 'টার্গেট বোনাস',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      debugPrint('✅ [TargetBonus] Batch committed — balance updated');
    } catch (e) {
      debugPrint('❌ [TargetBonus] Error: $e');
      rethrow;
    }
  }

  @override
  Future<int> getThisWeekVerifiedCount(String referCode) async {
    // Fetch network time and query users concurrently
    final results = await Future.wait([
      TimeUtils.getNetworkUtcTime(),
      _db
          .collection('users')
          .where('referredBy', isEqualTo: referCode)
          .where('subscriptionStatus', whereIn: SubscriptionStatus.strictPremium320Statuses)
          .get(),
    ]);

    final DateTime networkUtc = results[0] as DateTime;
    final QuerySnapshot<Map<String, dynamic>> query =
        results[1] as QuerySnapshot<Map<String, dynamic>>;

    final nowBst = networkUtc.add(const Duration(hours: 6));

    final mondayBst = nowBst.subtract(Duration(days: nowBst.weekday - 1));
    final weekStartBst = DateTime(mondayBst.year, mondayBst.month, mondayBst.day);
    final weekStartUtc = weekStartBst.subtract(const Duration(hours: 6)).toUtc();

    debugPrint(
      '🔥 [WeeklyBonus] Getting this week verified count for: $referCode (since $weekStartUtc UTC)',
    );

    final count = query.docs.where((doc) {
      final joinedAt = (doc.data()['joinedAt'] as Timestamp?)?.toDate();
      return joinedAt != null && joinedAt.isAfter(weekStartUtc);
    }).length;

    debugPrint('✅ [WeeklyBonus] This week verified: $count');
    return count;
  }

  @override
  Future<Map<String, dynamic>> loadWeeklyBonusStatus(String weekKey) async {
    debugPrint('🔥 [WeeklyBonus] Loading status for week: $weekKey');
    final uid = _uid;
    if (uid.isEmpty) throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');

    final claimDoc = await _db
        .collection('weekly_bonus_claims')
        .doc(uid)
        .collection('records')
        .doc(weekKey)
        .get();

    if (claimDoc.exists) {
      return claimDoc.data() ?? {};
    }

    return {'weekKey': weekKey, 'bonusClaimed': false};
  }

  @override
  Future<void> claimWeeklyBonus({
    required String weekKey,
    required double amount,
    required int verifiedCount,
  }) async {
    try {
      debugPrint('🔥 [WeeklyBonus] Starting claim for uid: $_uid');
      debugPrint('🔥 [WeeklyBonus] Amount: ৳$amount');
      final uid = _uid;
      if (uid.isEmpty) throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');

      // Re-calculate secure week key
      final networkUtc = await TimeUtils.getNetworkUtcTime();
      final nowBst = networkUtc.add(const Duration(hours: 6));
      final monday = nowBst.subtract(Duration(days: nowBst.weekday - 1));
      final secureWeekKey = '${monday.year}-W${monday.month}-${monday.day}';

      final claimRef = _db
          .collection('weekly_bonus_claims')
          .doc(uid)
          .collection('records')
          .doc(secureWeekKey);

      final claimDoc = await claimRef.get();
      if (claimDoc.exists && claimDoc.data()?['bonusClaimed'] == true) {
        throw Exception('এই বোনাস ইতোমধ্যে নেওয়া হয়েছে');
      }

      if (verifiedCount < 10) {
        throw Exception('not eligible');
      }

      final batch = _db.batch();

      // Add to user balance
      batch.update(_db.collection('users').doc(uid), {
        'balance.earning': FieldValue.increment(amount),
        'balance.total': FieldValue.increment(amount),
      });

      // Mark as claimed
      batch.set(claimRef, {
        'weekKey': secureWeekKey,
        'verifiedThisWeek': verifiedCount,
        'required': 10,
        'bonusClaimed': true,
        'claimedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add income history
      final historyRef = _db.collection('income_history').doc();
      batch.set(historyRef, {
        'uid': uid,
        'amount': amount,
        'type': 'weekly_bonus',
        'description': 'সাপ্তাহিক বোনাস',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      debugPrint('✅ [WeeklyBonus] Batch committed — balance updated');
    } catch (e) {
      debugPrint('❌ [WeeklyBonus] Error: $e');
      rethrow;
    }
  }

  // ── Monthly Bonus Implementation ─────────────────────────────────────────────

  /// Feature launch date cutoff — only referrals on or after this date count.
  /// BST (UTC+6): 2026-07-29 00:00:00
  static final DateTime _monthlyBonusLaunchDate = DateTime.utc(2026, 7, 28, 18, 0, 0); // = 2026-07-29 00:00 BST

  @override
  Future<Map<String, dynamic>> loadMonthlyBonusStatus() async {
    debugPrint('🔥 [MonthlyBonus] Loading cycle status');
    final uid = _uid;
    if (uid.isEmpty) throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');

    final networkUtc = await TimeUtils.getNetworkUtcTime();
    final nowBst = networkUtc.add(const Duration(hours: 6));

    final docRef = _db.collection('monthly_bonus_cycles').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // First time — initialise the cycle in Firestore and return defaults
      final cycleStart = nowBst;
      final cycleEnd = nowBst.add(const Duration(days: 30));
      final cycleKey = _ybCycleKey(cycleStart);
      await docRef.set({
        'cycleKey': cycleKey,
        'cycleStartDate': cycleStart.toUtc(),
        'cycleEndDate': cycleEnd.toUtc(),
        'isClaimed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return {
        'cycleKey': cycleKey,
        'cycleEndDate': cycleEnd,
        'isClaimed': false,
      };
    }

    final data = doc.data()!;
    final cycleEndTs = data['cycleEndDate'];
    DateTime cycleEnd;
    if (cycleEndTs is Timestamp) {
      cycleEnd = cycleEndTs.toDate().toUtc().add(const Duration(hours: 6));
    } else {
      cycleEnd = nowBst.add(const Duration(days: 30));
    }

    return {
      'cycleKey': data['cycleKey'] as String? ?? _ybCycleKey(nowBst),
      'cycleEndDate': cycleEnd,
      'isClaimed': data['isClaimed'] as bool? ?? false,
    };
  }

  @override
  Future<int> getMonthlyCycleVerifiedCount(String referCode) async {
    if (referCode.isEmpty) return 0;

    debugPrint('🔥 [MonthlyBonus] Counting referrals for: $referCode');

    // Load cycle data to get the cycle start date (all values in UTC)
    final docRef = _db.collection('monthly_bonus_cycles').doc(_uid);
    final doc = await docRef.get();

    DateTime cycleStart = _monthlyBonusLaunchDate;
    if (doc.exists) {
      final ts = doc.data()?['cycleStartDate'];
      if (ts is Timestamp) {
        cycleStart = ts.toDate().toUtc();
      }
    }

    // Count cutoff is the later of: feature launch date OR cycle start date (both UTC)
    final cutoffUtc = cycleStart.isAfter(_monthlyBonusLaunchDate)
        ? cycleStart
        : _monthlyBonusLaunchDate;
    final nowUtc = DateTime.now().toUtc();

    debugPrint('🔥 [MonthlyBonus] Cutoff UTC: $cutoffUtc | Now UTC: $nowUtc');

    final query = await _db
        .collection('users')
        .where('referredBy', isEqualTo: referCode)
        .where('subscriptionStatus', whereIn: SubscriptionStatus.strictPremium320Statuses)
        .get();

    final count = query.docs.where((doc) {
      final data = doc.data();
      final joinedAt = (data['joinedAt'] as Timestamp?)?.toDate();
      final verifiedAt = (data['verifiedAt'] as Timestamp?)?.toDate();

      final effectiveDate = verifiedAt ?? joinedAt;
      if (effectiveDate == null) return false;

      return effectiveDate.isAfter(cutoffUtc) && effectiveDate.isBefore(nowUtc);
    }).length;

    debugPrint('✅ [MonthlyBonus] Cycle verified count: $count');
    return count;
  }

  @override
  Future<void> claimMonthlyBonus({
    required String cycleKey,
    required double amount,
    required int verifiedCount,
  }) async {
    try {
      debugPrint('🔥 [MonthlyBonus] Starting claim for uid: $_uid');
      debugPrint('🔥 [MonthlyBonus] Amount: ৳$amount');
      final uid = _uid;
      if (uid.isEmpty) throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');

      // Re-validate server-side count
      final networkUtc = await TimeUtils.getNetworkUtcTime();
      final nowBst = networkUtc.add(const Duration(hours: 6));
      final userDoc = await _db.collection('users').doc(uid).get();
      final referCode = userDoc.data()?['referCode'] as String? ?? '';
      final liveCount = await getMonthlyCycleVerifiedCount(referCode);

      if (liveCount < 25) {
        throw Exception('not eligible - only $liveCount/25 verified');
      }

      final cycleRef = _db.collection('monthly_bonus_cycles').doc(uid);
      final cycleDoc = await cycleRef.get();
      if (cycleDoc.exists && cycleDoc.data()?['isClaimed'] == true) {
        throw Exception('already claimed');
      }

      final batch = _db.batch();

      // Credit wallet
      batch.update(_db.collection('users').doc(uid), {
        'balance.earning': FieldValue.increment(amount),
        'balance.total': FieldValue.increment(amount),
      });

      // Mark cycle as claimed + start a new cycle immediately
      final newCycleStart = nowBst;
      final newCycleEnd = nowBst.add(const Duration(days: 30));
      batch.set(cycleRef, {
        'cycleKey': _ybCycleKey(newCycleStart),
        'cycleStartDate': newCycleStart.toUtc(),
        'cycleEndDate': newCycleEnd.toUtc(),
        'isClaimed': false,
        'previousCycleClaimed': true,
        'previousCycleKey': cycleKey,
        'previousClaimedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: false));

      // Income history
      final historyRef = _db.collection('income_history').doc();
      batch.set(historyRef, {
        'uid': uid,
        'amount': amount,
        'type': 'monthly_bonus',
        'description': 'Monthly Bonus Reward - ৳300',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      debugPrint('✅ [MonthlyBonus] Batch committed — balance updated, new cycle started');
    } catch (e) {
      debugPrint('❌ [MonthlyBonus] Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetMonthlyCycle(DateTime nowBst) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    debugPrint('🔄 [MonthlyBonus] Auto-resetting expired cycle for uid: $uid');
    await _db.collection('monthly_bonus_cycles').doc(uid).set({
      'cycleKey': _ybCycleKey(nowBst),
      'cycleStartDate': nowBst.toUtc(),
      'cycleEndDate': nowBst.add(const Duration(days: 30)).toUtc(),
      'isClaimed': false,
      'resetAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: false));
  }

  String _ybCycleKey(DateTime bst) =>
      '${bst.year}-${bst.month.toString().padLeft(2, '0')}-${bst.day.toString().padLeft(2, '0')}';

  // ── Yearly Bonus ─────────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> loadYearlyBonusStatus() async {
    debugPrint('🔥 [YearlyBonus] Loading status');
    final uid = _uid;
    if (uid.isEmpty) throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');

    final docRef = _db.collection('bonus_claims').doc(uid).collection('yearly_bonus').doc('data');
    final doc = await docRef.get();
    
    if (!doc.exists) {
      return {'isClaimed': false};
    }
    
    return doc.data() ?? {'isClaimed': false};
  }

  @override
  Future<int> getYearlyTeamCount(String referCode) async {
    if (referCode.isEmpty) return 0;
    debugPrint('🔥 [YearlyBonus] Calculating 10-level team count for: $referCode');

    final featureLaunchDateUtc = DateTime.utc(2026, 7, 28, 18, 0, 0); // 2026-07-29 00:00 BST
    final nowUtc = DateTime.now().toUtc();
    int totalCount = 0;
    
    List<String> currentLevelCodes = [referCode];
    
    // Iterate exactly 10 levels deep
    for (int level = 1; level <= 10; level++) {
      if (currentLevelCodes.isEmpty) break; // Optimization: early exit if no children
      
      List<String> nextLevelCodes = [];
      int levelVerifiedCount = 0;
      
      // Batch queries in chunks of 30 due to whereIn limits
      final int chunkSize = 30;
      final List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [];
      
      for (int i = 0; i < currentLevelCodes.length; i += chunkSize) {
        final chunk = currentLevelCodes.sublist(
          i,
          i + chunkSize > currentLevelCodes.length ? currentLevelCodes.length : i + chunkSize,
        );
        
        // Fetch users referred by this chunk
        futures.add(
          _db.collection('users')
             .where('referredBy', whereIn: chunk)
             .where('subscriptionStatus', whereIn: SubscriptionStatus.strictPremium320Statuses)
             .get()
        );
      }
      
      final results = await Future.wait(futures);
      
      for (final query in results) {
        for (final doc in query.docs) {
          final data = doc.data();
          final userReferCode = data['referCode'] as String? ?? '';
          
          if (userReferCode.isNotEmpty) {
            nextLevelCodes.add(userReferCode);
          }
          
          // Check cutoff date
          final joinedAt = (data['joinedAt'] as Timestamp?)?.toDate();
          final verifiedAt = (data['verifiedAt'] as Timestamp?)?.toDate();
          final effectiveDate = verifiedAt ?? joinedAt;
          
          if (effectiveDate != null &&
              effectiveDate.isAfter(featureLaunchDateUtc) &&
              effectiveDate.isBefore(nowUtc)) {
            levelVerifiedCount++;
          }
        }
      }
      
      debugPrint('✅ [YearlyBonus] Level $level count: $levelVerifiedCount');
      totalCount += levelVerifiedCount;
      currentLevelCodes = nextLevelCodes;
    }
    
    debugPrint('🎉 [YearlyBonus] Total 10-level count: $totalCount');
    return totalCount;
  }

  @override
  Future<void> claimYearlyBonus({required int count}) async {
    try {
      final uid = _uid;
      if (uid.isEmpty) throw Exception('ব্যবহারকারী খুঁজে পাওয়া যায়নি');
      
      if (count < 3000) {
        throw Exception('not eligible - 3000 verified needed, got $count');
      }
      
      final docRef = _db.collection('bonus_claims').doc(uid).collection('yearly_bonus').doc('data');
      final doc = await docRef.get();
      if (doc.exists && doc.data()?['isClaimed'] == true) {
        throw Exception('already claimed');
      }
      
      final batch = _db.batch();
      final amount = 6000.0;
      
      // Credit wallet
      batch.update(_db.collection('users').doc(uid), {
        'balance.earning': FieldValue.increment(amount),
        'balance.total': FieldValue.increment(amount),
      });
      
      // Mark as claimed
      batch.set(docRef, {
        'isClaimed': true,
        'claimedCount': count,
        'claimedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Income history
      final historyRef = _db.collection('income_history').doc();
      batch.set(historyRef, {
        'uid': uid,
        'amount': amount,
        'type': 'yearly_bonus',
        'description': 'Yearly Bonus Target Reached - ৳6,000',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
      debugPrint('✅ [YearlyBonus] Batch committed — ৳6,000 rewarded');
    } catch (e) {
      debugPrint('❌ [YearlyBonus] Error: $e');
      rethrow;
    }
  }
}
