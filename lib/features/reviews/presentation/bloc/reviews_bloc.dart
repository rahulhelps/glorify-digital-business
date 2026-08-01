import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/reviews/domain/repositories/review_repository.dart';
import 'reviews_event.dart';
import 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repository;
  StreamSubscription? _subscription;
  int _currentSelection = 0;

  ReviewsBloc({required this.repository}) : super(ReviewInitial()) {
    on<LoadReviews>(_onLoadReviews);
    on<UpdateReviews>(_onUpdateReviews);
    on<SelectRating>(_onSelectRating);
    on<SubmitReview>(_onSubmitReview);
  }

  void _onLoadReviews(LoadReviews event, Emitter<ReviewState> emit) {
    emit(ReviewLoading());
    _subscription?.cancel();
    _subscription = repository.watchReviews().listen(
      (reviews) => add(UpdateReviews(reviews)),
      onError: (e) => add(UpdateReviews(const [])),
    );
  }

  void _onUpdateReviews(UpdateReviews event, Emitter<ReviewState> emit) {
    final reviews = event.reviews;
    final total = reviews.length;

    double avg = 0;
    double positive = 0;

    if (total > 0) {
      final sum = reviews
          .map((r) => (r['rating'] as num).toDouble())
          .reduce((a, b) => a + b);
      avg = sum / total;

      final positiveCount = reviews
          .where((r) => (r['rating'] as num) >= 4)
          .length;
      positive = (positiveCount / total) * 100;
    }

    emit(
      ReviewLoaded(
        reviews: reviews,
        averageRating: avg,
        totalCount: total,
        positivePercent: positive,
        userSelectedRating: _currentSelection,
      ),
    );
  }

  void _onSelectRating(SelectRating event, Emitter<ReviewState> emit) {
    _currentSelection = event.rating;
    if (state is ReviewLoaded) {
      emit((state as ReviewLoaded).copyWith(userSelectedRating: event.rating));
    }
  }

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewSubmitting());
    try {
      await repository.submitReview(
        uid: event.uid,
        userName: event.userName,
        userPhoto: event.userPhoto,
        rating: event.rating,
        comment: event.comment,
      );
      _currentSelection = 0;
      emit(ReviewSuccess());
      // Reload reviews
      add(LoadReviews());
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
