import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_strings.dart';
import 'package:global_earn/shared/widgets/home_icon_button.dart';
import 'package:global_earn/core/utils/url_launcher_utils.dart';

class SocialSupportSection extends StatelessWidget {
  const SocialSupportSection({super.key});

  static const _items = [
    (
      'assets/icons/facebook.png',
      AppStrings.socialFacebook,
      Color(0xFF1877F2), // icon color
      Color(0xFF0C5DC7), // gradientEnd (unused visually, kept for compat)
      Color(0xFFDCEBFF), // pastelBg — soft blue
      '',
    ),
    (
      'assets/icons/apple.png',
      AppStrings.socialWhatsapp,
      Color(0xFF25D366),
      Color(0xFF128C7E),
      Color(0xFFDCF5E8), // pastelBg — soft green
      '',
    ),
    (
      'assets/icons/telegram.png',
      AppStrings.socialTelegram,
      Color(0xFF2AABEE),
      Color(0xFF229ED9),
      Color(0xFFD6F0FF), // pastelBg — sky blue
      '',
    ),
    (
      'assets/icons/youtube.png',
      AppStrings.socialYoutube,
      Color(0xFFFF0000),
      Color(0xFFCC0000),
      Color(0xFFFFE0E0), // pastelBg — soft red
      '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F3960),
            blurRadius: 20.0,
            spreadRadius: 2,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4), // Cyan accent
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'অফিসিয়াল সাপোর্ট',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 16.0,
            children: _items
                .map(
                  (item) => HomeIconButton(
                        icon: item.$1,
                        label: item.$2,
                        gradientStart: item.$3,
                        gradientEnd: item.$4,
                        pastelBg: item.$5,
                        onTap: () => UrlLauncherUtils.launchSocialLink(item.$6),
                      ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
