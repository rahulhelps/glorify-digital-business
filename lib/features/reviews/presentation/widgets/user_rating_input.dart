import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:global_earn/features/reviews/presentation/bloc/reviews_event.dart';
import 'package:global_earn/features/reviews/presentation/bloc/reviews_state.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';

class UserRatingInput extends StatefulWidget {
  const UserRatingInput({super.key});

  @override
  State<UserRatingInput> createState() => _UserRatingInputState();
}

class _UserRatingInputState extends State<UserRatingInput> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final state = context.read<ReviewsBloc>().state;
    final userState = context.read<UserBloc>().state;

    if (state is! ReviewLoaded) return;
    if (userState is! UserLoaded) return;

    final rating = state.userSelectedRating;
    final comment = _commentController.text.trim();

    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('রেটিং নির্বাচন করুন'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (comment.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('মন্তব্য কমপক্ষে ১০ অক্ষর হতে হবে'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<ReviewsBloc>().add(
      SubmitReview(
        uid: userState.user.uid,
        userName: userState.user.name,
        userPhoto: userState
            .user
            .email, // Use email if photo not available, or placeholder
        rating: rating,
        comment: comment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewsBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSuccess) {
          _commentController.clear();
        }
      },
      builder: (context, state) {
        int selectedRating = 0;
        bool isSubmitting = state is ReviewSubmitting;

        if (state is ReviewLoaded) {
          selectedRating = state.userSelectedRating;
        }

        final int commentLength = _commentController.text.length;
        final bool isLong = commentLength > 480;

        return Column(
          children: [
            Text(
              'আপনার রেটিং দিন',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final ratingValue = index + 1;
                final bool isSelected = ratingValue <= selectedRating;
                return GestureDetector(
                  onTap: () => context.read<ReviewsBloc>().add(
                    SelectRating(ratingValue),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_outline,
                      color: isSelected ? AppColors.star : AppColors.outline,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSizes.spacingMd),
            Stack(
              children: [
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: 500,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'আপনার মতামত এখানে লিখুন...',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                      borderSide: const BorderSide(color: AppColors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Text(
                    '$commentLength/500',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isLong ? AppColors.error : AppColors.textSecondary,
                      fontWeight: isLong ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingLg),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                gradient: selectedRating > 0
                    ? const LinearGradient(
                        colors: [AppColors.primary, Color(0xFFff9f7d)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selectedRating > 0 ? null : Colors.grey.shade400,
              ),
              child: ElevatedButton(
                onPressed: isSubmitting || selectedRating == 0
                    ? null
                    : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'রিভিউ সাবমিট করুন',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
