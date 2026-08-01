import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/shared/widgets/home_icon_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/home/presentation/utils/premium_access_guard.dart';

// smm_sell feature imports removed — lib/features/smm_sell/ has been deleted.
// All items now fall through to isImplemented:false ("not available" placeholder).

class SmmServicesSection extends StatelessWidget {
  const SmmServicesSection({super.key});

  // (label, icon, iconColor, gradientEnd, pastelBg)
  // ⚠️ DO NOT reorder or remove any tuple — every tile must stay visible.
  static const _smmItems = [
    (
      'জিমেইল সেল', // index 0
      'assets/icons/email_sell.png',
      Color(0xFFEA4335), // Gmail red
      Color(0xFFFFBB33),
      Color(0xFFFFE4E0), // soft red-orange pastel
    ),
    (
      'ফেসবুক সেল', // index 1
      'assets/icons/facebook_sell.png',
      Color(0xFF1877F2), // Facebook blue
      Color(0xFF0C5DC7),
      Color(0xFFDCEBFF), // soft blue pastel
    ),
    (
      'ইনস্টাগ্রাম সেল', // index 2
      'assets/icons/instagram_sell.png',
      Color(0xFFE1306C), // Instagram magenta
      Color(0xFFF77737),
      Color(0xFFFFE0EE), // soft pink pastel
    ),
    (
      'হোয়াটসঅ্যাপ সেল',
      'assets/icons/whatsapp_sell.png',
      Color(0xFF25D366), // WhatsApp green
      Color(0xFF128C7E),
      Color(0xFFDCF5E8), // soft green pastel
    ),
    (
      'টেলিগ্রাম সেল',
      FontAwesomeIcons.telegram,
      Color(0xFF2AABEE), // Telegram blue
      Color(0xFF229ED9),
      Color(0xFFD6F0FF), // sky blue pastel
    ),
    (
      'টিকটক আইডি সেল',
      FontAwesomeIcons.tiktok,
      Color(0xFF4338CA), // indigo (TikTok alternative)
      Color(0xFFEE1D52),
      Color(0xFFE0E7FF), // indigo pastel
    ),
    (
      'টিকটক কয়েন সেল',
      FontAwesomeIcons.coins,
      Color(0xFFD97706), // amber/coins
      Color(0xFFFF5F00),
      Color(0xFFFEF3C7), // amber pastel
    ),
    (
      'এনএস ফলোয়ার্স',
      FontAwesomeIcons.userPlus,
      Color(0xFF7C3AED), // purple
      Color(0xFF3F3D9C),
      Color(0xFFEDE9FE), // lavender pastel
    ),
    (
      'নিবা কয়েন',
      FontAwesomeIcons.solidStar,
      Color(0xFFCA8A04), // gold
      Color(0xFFFFA500),
      Color(0xFFFFFBEB), // soft gold pastel
    ),
    (
      'এফবি পেজ সেল',
      FontAwesomeIcons.flag,
      Color(0xFF1877F2), // Facebook blue
      Color(0xFF42B72A),
      Color(0xFFDBEAFE), // periwinkle pastel
    ),
    (
      'এফবি ফলোয়ার্স সেল',
      FontAwesomeIcons.thumbsUp,
      Color(0xFF0284C7), // bright blue
      Color(0xFF0C5DC7),
      Color(0xFFE0F2FE), // sky pastel
    ),
    (
      'ইনস্টাগ্রাম ফলোয়ার্স',
      FontAwesomeIcons.heart,
      Color(0xFFE1306C), // Instagram pink
      Color(0xFFF77737),
      Color(0xFFFCE7F3), // rose pastel
    ),
    (
      'টিকটক ফলোয়ার্স',
      FontAwesomeIcons.personRunning,
      Color(0xFF0D9488), // teal
      Color(0xFFEE1D52),
      Color(0xFFCCFBF1), // teal pastel
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
          _SectionHeader(title: 'এসএমএম সার্ভিস 🔥', color: AppColors.primary),
          const SizedBox(height: AppSizes.spacingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _smmItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSizes.spacingMd,
              crossAxisSpacing: AppSizes.spacingXs,
              childAspectRatio: 0.90,
            ),
            itemBuilder: (context, i) => HomeIconButton(
              icon: _smmItems[i].$2,
              label: _smmItems[i].$1,
              gradientStart: _smmItems[i].$3,
              gradientEnd: _smmItems[i].$4,
              pastelBg: _smmItems[i].$5,
              onTap: () {
                final userState = context.read<UserBloc>().state;
                if (userState is! UserLoaded) return;

                // smm_sell feature deleted — all items show "not available" placeholder.
                navigateToFeature(
                  context: context,
                  user: userState.user,
                  featureName: _smmItems[i].$1,
                  isImplemented: false,
                  targetScreen: const SizedBox(),
                );
              },
            ),
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
