import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/shared/widgets/app_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Premium RegisterAppBar
//
// Design language:
//  • Deep navy → rich sapphire linear gradient (full-width)
//  • Subtle geometric micro-dot pattern painted over the gradient
//  • Cyan bottom border-glow for depth
//  • Elevated shadow with coloured tint
//  • Premium avatar action icon on the right
// ─────────────────────────────────────────────────────────────────────────────
class RegisterAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RegisterAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight + 4);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Base gradient container ─────────────────────────────────────────
        Container(
          height: AppSizes.appBarHeight + 4,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF061529), // deep navy
                Color(0xFF0A2040), // rich dark blue
                Color(0xFF0D2E58), // sapphire lift
              ],
            ),
            boxShadow: [
              // Pronounced coloured shadow for depth
              BoxShadow(
                color: Color(0xFF00CED1),
                blurRadius: 0,
                spreadRadius: 0,
                offset: Offset(0, 1), // bottom cyan glow-line
              ),
              BoxShadow(
                color: Color(0x5500CED1),
                blurRadius: 18,
                spreadRadius: 0,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0xCC000000),
                blurRadius: 28,
                spreadRadius: -4,
                offset: Offset(0, 8),
              ),
            ],
          ),
          // ── Geometric micro-pattern layer ─────────────────────────────────
          child: CustomPaint(
            painter: _HexMicroPatternPainter(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile,
              ),
              child: Row(
                children: [
                  // AppLogo fills the flex space
                  const Expanded(child: AppLogo()),
                  const SizedBox(width: AppSizes.spacingMd),
                  // Premium avatar action icon
                  _PremiumAvatarIcon(),
                ],
              ),
            ),
          ),
        ),
        // ── Bottom cyan accent line (1 px) ─────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFF00CED1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium avatar action icon (person placeholder with depth)
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumAvatarIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3A5C), Color(0xFF0D2240)],
        ),
        border: Border.all(
          color: const Color(0xFF00CED1).withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CED1).withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: Color(0xFF7EC8FF),
        size: 20,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Geometric micro-pattern painter (subtle hex dot grid)
// Renders a very subtle, repeating diagonal dot matrix over the gradient.
// All paint operations are transparent — purely decorative, no readability hit.
// ─────────────────────────────────────────────────────────────────────────────
class _HexMicroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00CED1).withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    const double spacing = 18;
    const double radius = 1.4;

    for (double y = 0; y <= size.height + spacing; y += spacing * 0.866) {
      final bool isOddRow = ((y / (spacing * 0.866)).round() % 2) == 1;
      final double xOffset = isOddRow ? spacing / 2 : 0;
      for (double x = xOffset; x <= size.width + spacing; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
