import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class LoadReviews extends ReviewEvent {}

class UpdateReviews extends ReviewEvent {
  final List<Map<String, dynamic>> reviews;
  const UpdateReviews(this.reviews);

  @override
  List<Object> get props => [reviews];
}

class SelectRating extends ReviewEvent {
  final int rating;
  const SelectRating(this.rating);

  @override
  List<Object> get props => [rating];
}

class SubmitReview extends ReviewEvent {
  final String uid;
  final String userName;
  final String userPhoto;
  final int rating;
  final String comment;

  const SubmitReview({
    required this.uid,
    required this.userName,
    required this.userPhoto,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object> get props => [uid, userName, userPhoto, rating, comment];
}
