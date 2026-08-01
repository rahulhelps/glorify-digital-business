import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

class PromotionalCard extends StatelessWidget {
  const PromotionalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfaceContainerHigh,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida/ADBb0uh3NNQ0JIWeNDVc3NDSQiL4lJZ-rmEshjj8NENTjz1CBatOMFYuryLyx1ZlZTGcqprm42pByW5O2uHfpRrqS_1-GXfUJWiZEhf93JUamiwv9bvBCFnVU2_SaRdra0NnJzvVuHqAacMNw_jsXq-tlp8sDTMtORavu7TFykmA6iSoME14bs9KjMKfZBi1OzK0YPpXgXGroAdePN9QPZyulf7HIipqxfGQ4SLinlB6d82o1mz6xoLkkipb_8dmx0rTbRE8VGAdI5JFc4k',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background,
                  AppColors.background.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Boost Your Growth',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Invite 5 more friends to unlock Gold Tier.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
