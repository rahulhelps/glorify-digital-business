import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/core/constants/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/home/presentation/utils/premium_access_guard.dart';
import 'package:global_earn/shared/widgets/home_icon_button.dart';
import 'package:global_earn/service_locator.dart';
import 'package:global_earn/features/home/presentation/screens/team_bonus_screen.dart';
import 'package:global_earn/features/home/presentation/bloc/bonus_bloc.dart';

// All other screen/bloc imports removed — their files have been deleted.
// Only TeamBonusScreen (index 1 = 'লিডারশিপ বোনাস') remains implemented.

class HomeProjectsSection extends StatelessWidget {
  const HomeProjectsSection({super.key});

  // (icon, label, iconColor, gradientEnd, pastelBg)
  // ⚠️ DO NOT reorder or remove any tuple — every tile must stay visible.
  static const _projects = [
    (
      'assets/icons/lucky_star.png',
      'লাকি স্টার্ট বোনাস',
      Color(0xFFDC2626),
      Color(0xFFFF8E53),
      Color(0xFFFFE4E4), // coral-salmon pastel
    ),
    (
      'assets/icons/leader.png',
      'লিডারশিপ বোনাস',
      Color(0xFF0284C7),
      Color(0xFF00F2FE),
      Color(0xFFDBEFFE), // sky blue pastel
    ),
    (
      'assets/icons/daily_bonus1.png',
      'ডেইলি বোনাস',
      Color(0xFF16A34A),
      Color(0xFF38F9D7),
      Color(0xFFDCFCE7), // mint green pastel
    ),
    (
      'assets/icons/terget_bonus.png',
      'টার্গেট বোনাস',
      Color(0xFFDB2777),
      Color(0xFFFEE140),
      Color(0xFFFCE7F3), // rose-pink pastel
    ),
    (
      'assets/icons/team_bonus1.png',
      'টিম বোনাস',
      Color(0xFF7C3AED),
      Color(0xFFFBC2EB),
      Color(0xFFEDE9FE), // lavender pastel
    ),
    (
      'assets/icons/rank.png',
      'র্যাংক',
      Color(0xFFD97706),
      Color(0xFFFFA500),
      Color(0xFFFEF3C7), // amber-yellow pastel
    ),
    (
      'assets/icons/iq_test1.png',
      'স্মার্ট টাস্ক',
      Color(0xFF4338CA),
      Color(0xFF04BEFE),
      Color(0xFFE0E7FF), // indigo pastel
    ),
    (
      'assets/icons/ads_view.png',
      'টাস্ক ভিউ',
      Color(0xFF0D9488),
      Color(0xFF3CBA92),
      Color(0xFFCCFBF1), // teal pastel
    ),
    (
      'assets/icons/typing_job1.png',
      'আইকিউ টেস্ট',
      Color(0xFF2563EB),
      Color(0xFFE0C3FC),
      Color(0xFFDBEAFE), // blue-violet pastel
    ),
    (
      'assets/icons/weekly_bonus.png',
      'উইকলি বোনাস',
      Color(0xFFBE185D),
      Color(0xFFFECFEF),
      Color(0xFFFCE7F3), // blush pastel
    ),
    (
      FontAwesomeIcons.calendarDays,
      'মান্থলি বোনাস',
      Color(0xFF15803D),
      Color(0xFFF9F586),
      Color(0xFFDCFCE7), // lime-mint pastel
    ),
    (
      FontAwesomeIcons.calendarCheck,
      'ইয়ারলি বোনাস',
      Color(0xFFC026D3),
      Color(0xFFF5576C),
      Color(0xFFFAE8FF), // magenta-soft pastel
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
          _SectionHeader(
              title: AppStrings.projectsTitle, color: AppColors.coral),
          const SizedBox(height: AppSizes.spacingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _projects.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSizes.spacingMd,
              crossAxisSpacing: AppSizes.spacingXs,
              childAspectRatio: 0.90,
            ),
            itemBuilder: (context, i) {
              final project = _projects[i];
              return HomeIconButton(
                icon: project.$1,
                label: project.$2,
                gradientStart: project.$3,
                gradientEnd: project.$4,
                pastelBg: project.$5,
                onTap: () => _handleProjectTap(context, i),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleProjectTap(BuildContext context, int index) {
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoaded) return;

    final project = _projects[index];
    final String label = project.$2;

    // Only index 1 ('লিডারশিপ বোনাস') is implemented.
    // All other indices tap → isImplemented:false → "not available" placeholder.
    final bool isImplemented = index == 1;

    Widget targetScreen = const SizedBox();
    if (index == 1) {
      // 'লিডারশিপ বোনাস' → TeamBonusScreen
      targetScreen = BlocProvider(
        create: (_) => sl<BonusBloc>(),
        child: const TeamBonusScreen(),
      );
    }
    // All other cases removed — their screens are deleted.

    navigateToFeature(
      context: context,
      user: userState.user,
      featureName: label,
      isImplemented: isImplemented,
      targetScreen: targetScreen,
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
