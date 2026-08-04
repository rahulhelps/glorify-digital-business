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
import 'package:global_earn/features/home/presentation/screens/team_bonus_screen.dart';
import 'package:global_earn/features/home/presentation/bloc/bonus_bloc.dart';

class HomeUnifiedProjectsSection extends StatelessWidget {
  const HomeUnifiedProjectsSection({super.key});

  // (icon, label, gradientStart, gradientEnd, pastelBg)
  static const List<(dynamic, String, Color, Color, Color)> _projects = [
    (
      'assets/icons/mobile_recharge.png', // 1
      'মোবাইল রিচার্জ',
      Color(0xFF0284C7), Color(0xFF00F2FE), Color(0xFFDBEFFE),
    ),
    (
      'assets/icons/drive_offers.png', // 2
      'রিচার্জ ড্রাইভ',
      Color(0xFF16A34A), Color(0xFF38F9D7), Color(0xFFDCFCE7),
    ),
    (
      'assets/icons/dropshipping.png', // 3
      'ড্রপ শিপিং',
      Color(0xFFDC2626), Color(0xFFFF8E53), Color(0xFFFFE4E4),
    ),
    (
      'assets/icons/mciro_job.png', // 4
      'মাইক্রো ওয়ার্ক',
      Color(0xFF7C3AED), Color(0xFFFBC2EB), Color(0xFFEDE9FE),
    ),
    (
      'assets/icons/mciro_job_post.png', // 5
      'ওয়ার্ক পোষ্ট',
      Color(0xFF059669), Color(0xFF3CBA92), Color(0xFFD1FAE5),
    ),
    (
      'assets/icons/ads_view.png', // 6
      'এড ভিউ',
      Color(0xFFC026D3), Color(0xFFF5576C), Color(0xFFFAE8FF),
    ),
    (
      'assets/icons/pre_apps.png', // 7
      'প্রি অ্যাপ',
      Color(0xFF2563EB), Color(0xFF04BEFE), Color(0xFFDBEAFE),
    ),
    (
      'assets/icons/course.png', // 8
      'কোর্স',
      Color(0xFFDB2777), Color(0xFFFEE140), Color(0xFFFCE7F3),
    ),
    (
      'assets/icons/leader.png', // 9
      'লিডারশিপ বোনাস',
      Color(0xFF0EA5E9), Color(0xFFE0C3FC), Color(0xFFE0F2FE),
    ),
    (
      'assets/icons/income_guide.png', // 10
      'ইনকাম গাইড',
      Color(0xFF0D9488), Color(0xFFF9F586), Color(0xFFCCFBF1),
    ),
    (
      'assets/icons/reveiw.png', // 11
      'রিভিউ জব',
      Color(0xFFD97706), Color(0xFFFFA500), Color(0xFFFEF3C7),
    ),
    (
      'assets/icons/lucky_star.png', // 12
      'লাকি স্টার্ট বোনাস',
      Color(0xFFDC2626), Color(0xFFFF8E53), Color(0xFFFFE4E4),
    ),
    (
      'assets/icons/tiktok_sell.png', // 13
      'টিক টক সেল',
      Color(0xFF4338CA), Color(0xFFEE1D52), Color(0xFFE0E7FF),
    ),
    (
      'assets/icons/blood_bank.png', // 14
      'ব্লাড ব্যাংক',
      Color(0xFFDC2626), Color(0xFFFF8E53), Color(0xFFFFE4E4),
    ),
    (
      'assets/icons/rank.png', // 15
      'র‍্যাংক',
      Color(0xFFD97706), Color(0xFFFFA500), Color(0xFFFEF3C7),
    ),
    (
      'assets/icons/terget_bonus.png', // 16
      'টার্গেট বোনাস',
      Color(0xFFDB2777), Color(0xFFFEE140), Color(0xFFFCE7F3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // color: Colors.deepOrange.withOpacity(0.02),
        color: Colors.white,
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
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.coral, AppColors.coral.withValues(alpha: 0.55)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'কাজ ও সেবা',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _projects.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, i) {
              final item = _projects[i];
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

                  if (label == 'রিচার্জ ড্রাইভ') {
                    context.push('/home/drive-offers');
                    return;
                  }

                  const implementedLabels = ['মোবাইল রিচার্জ', 'মাইক্রো ওয়ার্ক', 'ওয়ার্ক পোষ্ট', 'লিডারশিপ বোনাস'];
                  final bool isImplemented = implementedLabels.contains(label);

                  Widget targetScreen = const SizedBox();
                  if (label == 'ওয়ার্ক পোষ্ট') {
                    targetScreen = BlocProvider(
                      create: (_) => sl<PostJobBloc>(),
                      child: const PostMicroJobScreen(),
                    );
                  } else if (label == 'মাইক্রো ওয়ার্ক') {
                    targetScreen = BlocProvider(
                      create: (_) => sl<AvailableJobsBloc>(),
                      child: const MicroJobPanelScreen(),
                    );
                  } else if (label == 'মোবাইল রিচার্জ') {
                    targetScreen = BlocProvider(
                      create: (_) => sl<RechargeBloc>()..add(WatchRechargeBalance(userState.user.uid)),
                      child: const RechargeMainScreen(),
                    );
                  } else if (label == 'লিডারশিপ বোনাস') {
                    targetScreen = BlocProvider(
                      create: (_) => sl<BonusBloc>(),
                      child: const TeamBonusScreen(),
                    );
                  }

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
