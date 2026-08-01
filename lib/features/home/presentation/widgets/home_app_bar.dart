import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_strings.dart';

/// HomeAppBar rebuilt as a plain [StatelessWidget] (not PreferredSizeWidget).
/// It no longer lives in Scaffold.appBar — instead it sits inside a [Stack]
/// so the floating pill nav bar can overlap its bottom curve.
///
/// Visual design is intentionally unchanged:
///   • Blue gradient (1565C0 → 42A5F5, top-left → bottom-right)
///   • Rounded bottom corners (radius 22)
///   • Leading hamburger → Scaffold drawer
///   • Centered title
///   • Trailing notification icon with accent dot
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Keep status-bar icons white while this widget is visible.
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final topPadding = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(22),
        bottomRight: Radius.circular(22),
      ),
      child: Container(
        // Height = status bar + 64 (AppBar equivalent) + 32 extra for overlap zone
        height: topPadding + 64 + 32,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                // ── Hamburger / drawer ──────────────────────────────────────
                IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                ),

                // ── Title (centred) ─────────────────────────────────────────
                Expanded(
                  child: Center(
                    child: Text(
                      AppStrings.dashboardTitle,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),

                // ── Notification icon with dot ───────────────────────────────
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF42A5F5),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
