import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/home/presentation/utils/premium_access_guard.dart';
import 'package:global_earn/shared/widgets/home_icon_button.dart';
import 'package:global_earn/service_locator.dart';
import 'package:global_earn/features/home/presentation/screens/post_micro_job_screen.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_bloc.dart';
import 'package:global_earn/features/home/presentation/screens/micro_job_panel_screen.dart';
import 'package:global_earn/features/home/presentation/bloc/available_jobs_bloc.dart';
import 'package:global_earn/features/recharge/presentation/screens/recharge_main_screen.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_bloc.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_event.dart';

// AdsView imports removed — screen deleted, tap falls back to isImplemented:false

class HomeWorkSolutionSection extends StatelessWidget {
  const HomeWorkSolutionSection({super.key});

  // (icon, label, iconColor, gradientEnd, pastelBg)
  // ⚠️ DO NOT reorder or remove any tuple — every tile must stay visible.
  // Only the label for index 0 was renamed 'রিচার্জ' → 'মোবাইল রিচার্জ'.
  static const List<(dynamic, String, Color, Color, Color)> _workSolutions = [
    (
      'assets/icons/mobile_recharge.png',
      'মোবাইল রিচার্জ', // renamed from 'রিচার্জ'
      Color(0xFF0284C7),
      Color(0xFF00F2FE),
      Color(0xFFDBEFFE), // sky blue pastel
    ),
    (
      'assets/icons/drive_offers.png',
      'ড্রাইভ অফার',
      Color(0xFF16A34A),
      Color(0xFF38F9D7),
      Color(0xFFDCFCE7), // mint green pastel
    ),
    (
      'assets/icons/dropshipping.png',
      'রিসেলিং',
      Color(0xFFDC2626),
      Color(0xFFFF8E53),
      Color(0xFFFFE4E4), // peach pastel
    ),
    (
      'assets/icons/mciro_job.png',
      'মাইক্রো জব',
      Color(0xFF7C3AED),
      Color(0xFFFBC2EB),
      Color(0xFFEDE9FE), // lavender pastel
    ),
    (
      'assets/icons/mciro_job_post.png',
      'জব পোস্ট',
      Color(0xFF059669),
      Color(0xFF3CBA92),
      Color(0xFFD1FAE5), // seafoam pastel
    ),
    (
      'assets/icons/reveiw.png',
      'রিভিউ জব',
      Color(0xFFD97706),
      Color(0xFFFFA500),
      Color(0xFFFEF3C7), // amber pastel
    ),
    (
      'assets/icons/digital_service1.png',
      'ডিজিটাল সার্ভিস',
      Color(0xFF2563EB),
      Color(0xFF04BEFE),
      Color(0xFFDBEAFE), // periwinkle pastel
    ),
    (
      'assets/icons/bill_pay1.png',
      'বিল পে',
      Color(0xFFDB2777),
      Color(0xFFFEE140),
      Color(0xFFFCE7F3), // rose pastel
    ),
    (
      'assets/icons/vendor1.png',
      'ভেন্ডরশিপ',
      Color(0xFF0EA5E9),
      Color(0xFFE0C3FC),
      Color(0xFFE0F2FE), // light sky pastel
    ),
    (
      'assets/icons/extra_service1.png',
      'অ্যাডস ভিউ',
      Color(0xFFC026D3),
      Color(0xFFF5576C),
      Color(0xFFFAE8FF), // magenta pastel
    ),
    (
      'assets/icons/freelancing1.png',
      'ফ্রিল্যান্সিং',
      Color(0xFF0D9488),
      Color(0xFFF9F586),
      Color(0xFFCCFBF1), // teal pastel
    ),
    (
      'assets/icons/quran1.png',
      'কুরআন শিক্ষা',
      Color(0xFF15803D),
      Color(0xFF38F9D7),
      Color(0xFFDCFCE7), // soft green pastel
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
          _SectionHeader(title: 'কাজের সমাধান', color: AppColors.coral),
          const SizedBox(height: AppSizes.spacingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _workSolutions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSizes.spacingMd,
              crossAxisSpacing: AppSizes.spacingXs,
              childAspectRatio: 0.90,
            ),
            itemBuilder: (context, i) {
              final item = _workSolutions[i];
              return HomeIconButton(
                icon: item.$1,
                label: item.$2,
                gradientStart: item.$3,
                gradientEnd: item.$4,
                pastelBg: item.$5,
                onTap: () {
                  final userState = context.read<UserBloc>().state;
                  if (userState is! UserLoaded) return;

                  final String label = item.$2;

                  if (label == 'ড্রাইভ অফার') {
                    context.push('/home/drive-offers');
                    return;
                  }

                  // Only 3 items remain truly implemented:
                  //   'মোবাইল রিচার্জ' (index 0), 'মাইক্রো জব' (index 3),
                  //   'জব পোস্ট' (index 4).
                  // All others (incl. Ads View) fall through to isImplemented:false.
                  const implementedLabels = ['মোবাইল রিচার্জ', 'মাইক্রো জব', 'জব পোস্ট'];
                  final bool isImplemented = implementedLabels.contains(label);

                  Widget targetScreen = const SizedBox();
                  if (label == 'জব পোস্ট') {
                    targetScreen = BlocProvider(
                      create: (_) => sl<PostJobBloc>(),
                      child: const PostMicroJobScreen(),
                    );
                  } else if (label == 'মাইক্রো জব') {
                    targetScreen = BlocProvider(
                      create: (_) => sl<AvailableJobsBloc>(),
                      child: const MicroJobPanelScreen(),
                    );
                  } else if (label == 'মোবাইল রিচার্জ') {
                    targetScreen = BlocProvider(
                      create: (_) => sl<RechargeBloc>()..add(WatchRechargeBalance(userState.user.uid)),
                      child: const RechargeMainScreen(),
                    );
                  }
                  // All other labels: isImplemented=false, targetScreen=SizedBox()
                  // → navigateToFeature shows "not available yet" placeholder.

                  navigateToFeature(
                    context: context,
                    user: userState.user,
                    featureName: label,
                    isImplemented: isImplemented,
                    targetScreen: targetScreen,
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
