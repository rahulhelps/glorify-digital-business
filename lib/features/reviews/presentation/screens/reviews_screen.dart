import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:global_earn/features/reviews/presentation/bloc/reviews_event.dart';
import 'package:global_earn/features/reviews/presentation/bloc/reviews_state.dart';
import 'package:global_earn/features/reviews/presentation/widgets/overall_rating_card.dart';
import 'package:global_earn/features/reviews/presentation/widgets/recent_reviews_list.dart';
import 'package:global_earn/features/reviews/presentation/widgets/reviews_bento_grid.dart';
import 'package:global_earn/features/reviews/presentation/widgets/user_rating_input.dart';
import 'package:global_earn/service_locator.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ReviewsBloc>()..add(LoadReviews()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: const Text(
            'রেটিংস & রিভিউ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocListener<ReviewsBloc, ReviewState>(
          listener: (context, state) {
            if (state is ReviewSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('রিভিউ সফলভাবে জমা হয়েছে'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is ReviewError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: const SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.marginMobile,
              vertical: AppSizes.spacingLg,
            ),
            child: Column(
              children: [
                OverallRatingCard(),
                SizedBox(height: AppSizes.spacingLg),
                ReviewsBentoGrid(),
                SizedBox(height: AppSizes.spacingLg),
                UserRatingInput(),
                SizedBox(height: AppSizes.spacingLg),
                RecentReviewsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
