import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/network/data/models/downline_user_model.dart';
import 'package:global_earn/features/network/domain/repositories/network_repository.dart';
import 'dart:developer' as dev;

class NetworkRepositoryImpl implements NetworkRepository {
  final FirebaseFirestore _firestore;

  NetworkRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Upline ────────────────────────────────────────────────────────────────

  @override
  Future<List<UserModel>> getUplineChain(String startReferredBy) async {
    dev.log(
      '🔥 [UplineReport] Fetching direct upline (1-level only)...',
      name: 'Network',
    );
    final List<UserModel> chain = [];
    final String currentReferCode = startReferredBy;

    try {
      // Limit: fetch ONLY the immediate referrer (1 level). The loop cap is
      // intentionally set to 1 — do NOT increase without product approval.
      for (int i = 0; i < 1; i++) {
        if (currentReferCode.isEmpty) break;

        final query = await _firestore
            .collection('users')
            .where('referCode', isEqualTo: currentReferCode)
            .limit(1)
            .get();

        if (query.docs.isEmpty) break;

        final data = query.docs.first.data();
        final upline = UserModel.fromJson(data);
        chain.add(upline);
        // NOTE: We do NOT follow upline.referredBy — 1 level max.
      }
      dev.log(
        '✅ [UplineReport] Direct upline found: ${chain.length}',
        name: 'Network',
      );
      return chain;
    } catch (e) {
      dev.log('❌ [UplineReport] Error: $e', name: 'Network');
      rethrow;
    }
  }

  // ─── Downline ──────────────────────────────────────────────────────────────

  @override
  Future<List<DownlineUserModel>> getAllDownlines(String referCode) async {
    dev.log(
      '🔥 [Downline] Loading downlines for referCode: $referCode',
      name: 'Network',
    );

    final List<DownlineUserModel> allDownlines = [];
    List<String> currentLevelCodes = [referCode];
    int level = 1;

    try {
      while (currentLevelCodes.isNotEmpty && level <= 10) {
        final List<String> nextLevelCodes = [];

        final List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [];

        // Firestore `whereIn` limit is 30 — query in batches concurrently
        for (int i = 0; i < currentLevelCodes.length; i += 30) {
          final batch = currentLevelCodes.sublist(
            i,
            min(i + 30, currentLevelCodes.length),
          );

          final future = _firestore
              .collection('users')
              .where('referredBy', whereIn: batch)
              .get();
          futures.add(future);
        }

        final List<QuerySnapshot<Map<String, dynamic>>> results =
            await Future.wait(futures);

        for (final query in results) {
          for (final doc in query.docs) {
            final data = doc.data();
            allDownlines.add(
              DownlineUserModel.fromFirestore(data, doc.id, level),
            );
            final rc = data['referCode'] as String? ?? '';
            if (rc.isNotEmpty) nextLevelCodes.add(rc);
          }
        }

        dev.log(
          '✅ [Downline] Level $level: found ${nextLevelCodes.length} users',
          name: 'Network',
        );

        currentLevelCodes = nextLevelCodes;
        level++;
      }

      dev.log(
        '✅ [Downline] Total downlines: ${allDownlines.length}',
        name: 'Network',
      );
      return allDownlines;
    } catch (e) {
      dev.log('❌ [Downline] Error: $e', name: 'Network');
      rethrow;
    }
  }

  @override
  Future<(List<DownlineUserModel>, DocumentSnapshot?)> getPaginatedDownlines(
    String referCode, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    dev.log('🔥 [Downline] Fetching paginated direct downlines for $referCode', name: 'Network');
    
    try {
      Query query = _firestore
          .collection('users')
          .where('referredBy', isEqualTo: referCode)
          .orderBy('joinedAt', descending: true)
          .limit(limit);
          
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get(const GetOptions(source: Source.serverAndCache));
      
      final users = snapshot.docs.map((doc) {
        return DownlineUserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id, 1);
      }).toList();
      
      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      
      return (users, lastDoc);
    } catch (e) {
      dev.log('❌ [Downline] Pagination Error: $e', name: 'Network');
      rethrow;
    }
  }
}
