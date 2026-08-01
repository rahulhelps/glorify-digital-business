import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/reviews/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _firestore;
  final NetworkInfo _networkInfo;

  ReviewRepositoryImpl({
    required FirebaseFirestore firestore,
    required NetworkInfo networkInfo,
  }) : _firestore = firestore,
       _networkInfo = networkInfo;

  @override
  Stream<List<Map<String, dynamic>>> watchReviews() {
    dev.log('🔥 [Review] Loading reviews...');
    return _firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
          double avg = 0;
          if (reviews.isNotEmpty) {
            avg =
                reviews
                    .map((r) => (r['rating'] as num).toDouble())
                    .reduce((a, b) => a + b) /
                reviews.length;
          }
          dev.log(
            '✅ [Review] Found ${reviews.length} reviews, avg: ${avg.toStringAsFixed(1)}',
          );
          return reviews;
        });
  }

  @override
  Future<void> submitReview({
    required String uid,
    required String userName,
    required String userPhoto,
    required int rating,
    required String comment,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw 'ইন্টারনেট সংযোগ নেই';
    }

    try {
      dev.log('🔥 [Review] Submitting review: $rating stars');
      final query = await _firestore
          .collection('reviews')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      final data = {
        'uid': uid,
        'userName': userName,
        'userPhoto': userPhoto,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update(data);
      } else {
        await _firestore.collection('reviews').add(data);
      }
      dev.log('✅ [Review] Review submitted');
    } catch (e) {
      dev.log('❌ [Review] Error: $e');
      throw 'রিভিউ জমা দিতে সমস্যা হয়েছে';
    }
  }
}
