import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // আপনার ব্যানারের কর্নার রেডিয়াসের সাথে মিল রাখুন
        border: Border.all(
          color: Colors.grey.withOpacity(0.5), // খুব হালকা গ্রে বর্ডার
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        child: SizedBox(
          height: AppSizes.heroHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/top_header_image.png',
                fit: BoxFit.fill,
                errorBuilder: (ctx, e, s) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1205), Color(0xFF3D2B00)],
                    ),
                  ),
                ),
              ),
              // Container(
              //   decoration: const BoxDecoration(
              //     gradient: LinearGradient(
              //       colors: [Color(0xCC000000), Colors.transparent],
              //       stops: [0.0, 0.7],
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(AppSizes.spacingLg),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         AppStrings.heroTagline,
              //         style: GoogleFonts.manrope(
              //           fontSize: 20,
              //           fontWeight: FontWeight.w600,
              //           color: AppColors.secondary,
              //         ),
              //       ),
              //       const SizedBox(height: AppSizes.spacingXs),
              //       Text(
              //         AppStrings.heroSubtitle,
              //         style: const TextStyle(
              //           fontSize: 14,
              //           color: AppColors.white80,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
      )
    );
  }
}
