import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/features/home/presentation/utils/premium_access_guard.dart';
// smm_sell feature deleted — imports removed.
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/shared/widgets/home_icon_button.dart';

// ─── Service Data Model ───────────────────────────────────────────────────────

typedef _SmmItem = ({
  dynamic icon,
  String label,
  Color gradientStart,
  Color gradientEnd,
  Color pastelBg,
});

// ─── AllServicesScreen (SMM Only) ─────────────────────────────────────────────

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  /// SMM-only service list — all 13 items, displayed in a unified 4-column grid.
  static final List<_SmmItem> _smmItems = [
    (
      icon: 'assets/icons/email_sell.png',
      label: 'Gmail Sell',
      gradientStart: const Color(0xFFEA4335),
      gradientEnd: const Color(0xFFFFBB33),
      pastelBg: const Color(0xFFFFE4E0),
    ),
    (
      icon: 'assets/icons/facebook_sell.png',
      label: 'Facebook Sell',
      gradientStart: const Color(0xFF1877F2),
      gradientEnd: const Color(0xFF0C5DC7),
      pastelBg: const Color(0xFFDCEBFF),
    ),
    (
      icon: 'assets/icons/instagram_sell.png',
      label: 'Instagram Sell',
      gradientStart: const Color(0xFFE1306C),
      gradientEnd: const Color(0xFFF77737),
      pastelBg: const Color(0xFFFFE0EE),
    ),
    (
      icon: 'assets/icons/whatsapp_sell.png',
      label: 'WhatsApp Sell',
      gradientStart: const Color(0xFF25D366),
      gradientEnd: const Color(0xFF128C7E),
      pastelBg: const Color(0xFFDCF5E8),
    ),
    (
      icon: FontAwesomeIcons.telegram,
      label: 'Telegram Sell',
      gradientStart: const Color(0xFF2AABEE),
      gradientEnd: const Color(0xFF229ED9),
      pastelBg: const Color(0xFFD6F0FF),
    ),
    (
      icon: FontAwesomeIcons.tiktok,
      label: 'TikTok ID Sell',
      gradientStart: const Color(0xFF4338CA),
      gradientEnd: const Color(0xFFEE1D52),
      pastelBg: const Color(0xFFE0E7FF),
    ),
    (
    icon: 'assets/icons/tiktok_sell.png',
      label: 'TikTok Coins Sell',
      gradientStart: const Color(0xFFD97706),
      gradientEnd: const Color(0xFFFF5F00),
      pastelBg: const Color(0xFFFEF3C7),
    ),
    (
      icon: FontAwesomeIcons.userPlus,
      label: 'NS Followers',
      gradientStart: const Color(0xFF7C3AED),
      gradientEnd: const Color(0xFF3F3D9C),
      pastelBg: const Color(0xFFEDE9FE),
    ),
    (
      icon: FontAwesomeIcons.solidStar,
      label: 'Niba Coins',
      gradientStart: const Color(0xFFCA8A04),
      gradientEnd: const Color(0xFFFFA500),
      pastelBg: const Color(0xFFFFFBEB),
    ),
    (
      icon: FontAwesomeIcons.flag,
      label: 'FB Page Sell',
      gradientStart: const Color(0xFF1877F2),
      gradientEnd: const Color(0xFF42B72A),
      pastelBg: const Color(0xFFDBEAFE),
    ),
    (
      icon: FontAwesomeIcons.thumbsUp,
      label: 'FB Followers Sell',
      gradientStart: const Color(0xFF0284C7),
      gradientEnd: const Color(0xFF0C5DC7),
      pastelBg: const Color(0xFFE0F2FE),
    ),
    (
      icon: FontAwesomeIcons.heart,
      label: 'Instagram Followers',
      gradientStart: const Color(0xFFE1306C),
      gradientEnd: const Color(0xFFF77737),
      pastelBg: const Color(0xFFFCE7F3),
    ),
    (
      icon: FontAwesomeIcons.personRunning,
      label: 'TikTok Followers',
      gradientStart: const Color(0xFF0D9488),
      gradientEnd: const Color(0xFFEE1D52),
      pastelBg: const Color(0xFFCCFBF1),
    ),
  ];

  // ── SMM tap handler ───────────────────────────────────────────────────────

  void _onTap(BuildContext context, _SmmItem item) {
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoaded) return;

    // smm_sell feature deleted — all items show "not available" placeholder.
    navigateToFeature(
      context: context,
      user: userState.user,
      featureName: item.label,
      isImplemented: false,
      targetScreen: const SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      // ── Gradient AppBar ────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0d3b66), Color(0xFF097CCB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    splashRadius: 22,
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SMM Services',
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'সকল এসএমএম সার্ভিস',
                          style: GoogleFonts.manrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Decorative badge
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // ── Body: SMM-only grid with staggered entrance animation ──────────────
      body: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _smmItems.length,
        itemBuilder: (context, index) {
          final item = _smmItems[index];

          // Staggered entrance: slide up 30 px + fade in, delay scales with index
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: HomeIconButton(
              icon: item.icon,
              label: item.label,
              gradientStart: item.gradientStart,
              gradientEnd: item.gradientEnd,
              pastelBg: item.pastelBg,
              onTap: () => _onTap(context, item),
            ),
          );
        },
      ),
    );
  }
}
