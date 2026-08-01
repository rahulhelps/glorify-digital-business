import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/home/presentation/utils/premium_access_guard.dart';
import 'package:global_earn/shared/widgets/home_icon_button.dart';

class SpecialServicesSection extends StatelessWidget {
  const SpecialServicesSection({super.key});

  // (icon, label, iconColor, gradientEnd, pastelBg)
  static const _services = [
    (
      'assets/icons/blood_bank.png',
      'রক্তদান',
      Color(0xFFDC2626),
      Color(0xFFFF8E53),
      Color(0xFFFFE4E4), // soft red-rose pastel
    ),
    (
    'assets/icons/course.png',
      'কোর্স',
      Color(0xFF2563EB),
      Color(0xFF04BEFE),
      Color(0xFFDBEAFE), // soft blue pastel
    ),
    (
      FontAwesomeIcons.piggyBank,
      'মেম্বার ফান্ড',
      Color(0xFF16A34A),
      Color(0xFF38F9D7),
      Color(0xFFDCFCE7), // soft green pastel
    ),
    (
      FontAwesomeIcons.circleCheck,
      'ভেরিফাই ব্যানার',
      Color(0xFF0284C7),
      Color(0xFF00F2FE),
      Color(0xFFE0F2FE), // cyan-sky pastel
    ),
    (
      FontAwesomeIcons.paperPlane,
      'টাকা পাঠান',
      Color(0xFF7C3AED),
      Color(0xFFFBC2EB),
      Color(0xFFEDE9FE), // soft purple pastel
    ),
    (
      FontAwesomeIcons.mosque,
      'নামাজের সময়',
      Color(0xFF0D9488),
      Color(0xFF3CBA92),
      Color(0xFFCCFBF1), // soft teal pastel
    ),
    (
      FontAwesomeIcons.gift,
      'লিডার গিফট',
      Color(0xFFD97706),
      Color(0xFFFFA500),
      Color(0xFFFEF3C7), // soft amber-gold pastel
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16.0,
            spreadRadius: 0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'সার্ভিস হাব', color: AppColors.coral),
          const SizedBox(height: AppSizes.spacingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSizes.spacingMd,
              crossAxisSpacing: AppSizes.spacingXs,
              childAspectRatio: 0.90, // 3-column layout: wider cards, balanced aspect ratio
            ),
            itemBuilder: (context, i) {
              // Regular service tiles
              return HomeIconButton(
                icon: _services[i].$1,
                label: _services[i].$2,
                gradientStart: _services[i].$3,
                gradientEnd: _services[i].$4,
                pastelBg: _services[i].$5,
                onTap: () {
                  final userState = context.read<UserBloc>().state;
                  if (userState is! UserLoaded) return;

                  navigateToFeature(
                    context: context,
                    user: userState.user,
                    featureName: _services[i].$2,
                    isImplemented: false,
                    targetScreen: const SizedBox(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.55)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
