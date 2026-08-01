import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/core/constants/app_strings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Premium AppBar brand logo: gradient badge + responsive text.
// Wrapped in Flexible → safe inside Expanded(child: AppLogo()).
// ─────────────────────────────────────────────────────────────────────────────
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Premium octagon-style gradient badge ──────────────────────────
        _LogoBadge(),
        const SizedBox(width: 12),
        // ── Title block: two-line, never overflows ────────────────────────
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF7EC8FF), Color(0xFF00CED1)],
                ).createShader(bounds),
                child: Text(
                  AppStrings.appNameShort.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.4,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Digital Business Platform',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.white54,
                  letterSpacing: 0.6,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium gradient logo badge (replaces rudimentary circle)
// ─────────────────────────────────────────────────────────────────────────────
class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.logoSize,
      height: AppSizes.logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E90FF), Color(0xFF00CED1)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CED1).withValues(alpha: 0.45),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // Inner dark ring + "GP" monogram
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0A1628),
          ),
          alignment: Alignment.center,
          child: ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFF7EC8FF), Color(0xFF00CED1)],
            ).createShader(b),
            child: Text(
              'GP',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppLogo short variant (app name only — for splash / elsewhere if needed)
// ─────────────────────────────────────────────────────────────────────────────
class AppLogoShort extends StatelessWidget {
  const AppLogoShort({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoBadge(),
        const SizedBox(width: 10),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [AppColors.coral, AppColors.cyan],
          ).createShader(b),
          child: Text(
            AppStrings.appNameShort,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
