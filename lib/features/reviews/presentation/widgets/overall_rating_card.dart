import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:global_earn/features/reviews/presentation/bloc/reviews_state.dart';

class OverallRatingCard extends StatelessWidget {
  const OverallRatingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewsBloc, ReviewState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        double avg = 0;
        int total = 0;
        double positive = 0;

        if (state is ReviewLoaded) {
          avg = state.averageRating;
          total = state.totalCount;
          positive = state.positivePercent;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.spacingLg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < avg.floor()
                        ? Icons.star
                        : (index < avg ? Icons.star_half : Icons.star_border),
                    color: AppColors.star,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                'Total ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Reviews',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${positive.toStringAsFixed(0)}% Positive Feedback',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
