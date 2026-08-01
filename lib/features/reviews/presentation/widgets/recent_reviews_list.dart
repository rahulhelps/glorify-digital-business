import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:global_earn/features/reviews/presentation/bloc/reviews_state.dart';

class RecentReviewsList extends StatelessWidget {
  const RecentReviewsList({super.key});

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} দিন আগে';
    if (diff.inHours > 0) return '${diff.inHours} ঘন্টা আগে';
    if (diff.inMinutes > 0) return '${diff.inMinutes} মিনিট আগে';
    return 'এইমাত্র';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewsBloc, ReviewState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is ReviewLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is! ReviewLoaded || state.reviews.isEmpty) {
          return const SizedBox.shrink();
        }

        final recentReviews = state.reviews.take(5).toList();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'সাম্প্রতিক রিভিউ',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to all reviews or show bottom sheet
                  },
                  child: Text(
                    'সব দেখুন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMd),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentReviews.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSizes.spacingMd),
              itemBuilder: (context, index) {
                final review = recentReviews[index];
                final createdAt = review['createdAt'];
                DateTime date = DateTime.now();
                if (createdAt is Timestamp) {
                  date = createdAt.toDate();
                }

                return _buildReviewCard(
                  name: review['userName'] ?? 'Unknown User',
                  rating: (review['rating'] as num).toInt(),
                  date: timeAgo(date),
                  comment: review['comment'] ?? '',
                  imageUrl: review['userPhoto'] ?? '',
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard({
    required String name,
    required int rating,
    required String date,
    required String comment,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.outline),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: AppColors.primary),
                      )
                    : const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: AppSizes.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: AppColors.star,
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                date,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSm),
          Text(
            comment,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

