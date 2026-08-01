import 'package:equatable/equatable.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<Map<String, dynamic>> reviews;
  final double averageRating;
  final int totalCount;
  final double positivePercent;
  final int userSelectedRating;

  const ReviewLoaded({
    required this.reviews,
    required this.averageRating,
    required this.totalCount,
    required this.positivePercent,
    this.userSelectedRating = 0,
  });

  ReviewLoaded copyWith({
    List<Map<String, dynamic>>? reviews,
    double? averageRating,
    int? totalCount,
    double? positivePercent,
    int? userSelectedRating,
  }) {
    return ReviewLoaded(
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      totalCount: totalCount ?? this.totalCount,
      positivePercent: positivePercent ?? this.positivePercent,
      userSelectedRating: userSelectedRating ?? this.userSelectedRating,
    );
  }

  @override
  List<Object?> get props => [
    reviews,
    averageRating,
    totalCount,
    positivePercent,
    userSelectedRating,
  ];
}

class ReviewSubmitting extends ReviewState {}

class ReviewSuccess extends ReviewState {}

class ReviewError extends ReviewState {
  final String message;
  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}
