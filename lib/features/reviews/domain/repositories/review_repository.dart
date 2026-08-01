abstract class ReviewRepository {
  Stream<List<Map<String, dynamic>>> watchReviews();
  Future<void> submitReview({
    required String uid,
    required String userName,
    required String userPhoto,
    required int rating,
    required String comment,
  });
}
