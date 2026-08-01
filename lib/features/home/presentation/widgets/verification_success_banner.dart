import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';

// ─── Brand color aliases (matching verification_plan_screen.dart) ────────────
const Color _kPrimaryBlue = Color(0xFF0F3D88); // AppColors.cyan
const Color _kAccentBlue = Color(0xFF097CCB); // AppColors.coral/primary
const Color _kGold = Color(0xFFFFC107); // AppColors.star

class VerificationSuccessBanner extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDismiss;

  const VerificationSuccessBanner({
    super.key,
    required this.user,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Overlap amount: how much the avatar overhangs the curved header
    const double avatarOverlap = 52.0;
    const double avatarTotal = 116.0; // outer diameter incl. white ring

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // ── Curved header ────────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Header background with curved bottom
                ClipPath(
                  clipper: _ArchClipper(),
                  child: Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_kPrimaryBlue, Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Scattered sparkle decorations
                        const _SparkleDecor(),
                        // Header text content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 18),
                              // Shield-check icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.verified_user_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // "— ভেরিফাই —"
                              Text(
                                '— ভেরিফাই —',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  letterSpacing: 2.5,
                                ),
                              ),
                              // "সফল হয়েছে"
                              Text(
                                'সফল হয়েছে',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: _kGold,
                                  height: 1.15,
                                ),
                              ),
                              // Extra space so arch clip doesn't cut text
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── White body (the overlap is eaten by SizedBox below) ──────────
            Container(
              color: AppColors.surface,
              child: Column(
                children: [
                  // Space that accounts for the half of avatar hanging into body
                  const SizedBox(height: avatarOverlap + 12),

                  // 🎉 অভিনন্দন!
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 6),
                      Text(
                        'অভিনন্দন!',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: _kPrimaryBlue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Name pill with dot-line flourishes
                  _NamePill(name: user.name),

                  const SizedBox(height: 14),

                  // Verification active badge
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: _kAccentBlue.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _kAccentBlue.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: _kGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'ভেরিফিকেশন একটিভেট হয়েছে',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kPrimaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Congratulatory paragraph
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'অভিনন্দন এখন থেকে আপনি সকল প্রিমিয়াম সুবিধা ও বিশেষ ফিচার উপভোগ করতে পারবেন।',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ঠিক আছে button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onDismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor:
                              _kPrimaryBlue.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'ঠিক আছে',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 200 - avatarOverlap,
          left: 0,
          right: 0,
          child: Center(
            child: _AvatarWithBadge(user: user, size: avatarTotal),
          ),
        ),
      ],
    ),
  ),
);
  }
}

// ─── Arch / wave clipper for the header ──────────────────────────────────────
class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 36,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_ArchClipper oldClipper) => false;
}

// ─── Circular avatar + verified badge ────────────────────────────────────────
class _AvatarWithBadge extends StatelessWidget {
  final UserModel user;
  final double size;

  const _AvatarWithBadge({required this.user, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // White ring
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: _kPrimaryBlue.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: ClipOval(
            child: Container(
              color: AppColors.surfaceContainerHigh,
              child: user.profileImageUrl != null &&
                      user.profileImageUrl!.isNotEmpty
                  ? Image.network(
                      user.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.person,
                        size: 52,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 52,
                      color: AppColors.textSecondary,
                    ),
            ),
          ),
        ),
        // Verified badge at bottom-right
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: _kAccentBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Name pill with dot-line flourishes ──────────────────────────────────────
class _NamePill extends StatelessWidget {
  final String name;

  const _NamePill({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Left flourish  ──•
        _Flourish(isLeft: true),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(color: _kPrimaryBlue, width: 1.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            name,
            style: GoogleFonts.hindSiliguri(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Right flourish  •──
        _Flourish(isLeft: false),
      ],
    );
  }
}

class _Flourish extends StatelessWidget {
  final bool isLeft;

  const _Flourish({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: isLeft
          ? [
              Container(
                  width: 20,
                  height: 1.5,
                  color: _kPrimaryBlue.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kPrimaryBlue.withValues(alpha: 0.7),
                ),
              ),
            ]
          : [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kPrimaryBlue.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                  width: 20,
                  height: 1.5,
                  color: _kPrimaryBlue.withValues(alpha: 0.5)),
            ],
    );
  }
}

// ─── Scattered sparkle / confetti decorations inside the header ───────────────
class _SparkleDecor extends StatelessWidget {
  const _SparkleDecor();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      return Stack(
        children: [
          // Top-left small dot
          _dot(left: w * 0.08, top: h * 0.12, size: 7, color: _kGold),
          // Top-right ribbon arc (CustomPaint)
          Positioned(
            right: w * 0.06,
            top: h * 0.08,
            child: _TinyArc(color: _kGold.withValues(alpha: 0.85), size: 18),
          ),
          // Mid-left sparkle star
          Positioned(
            left: w * 0.05,
            top: h * 0.48,
            child: _StarIcon(color: Colors.white.withValues(alpha: 0.6), size: 14),
          ),
          // Mid-right dot
          _dot(right: w * 0.08, top: h * 0.38, size: 6, color: Colors.white.withValues(alpha: 0.5)),
          // Lower-left arc
          Positioned(
            left: w * 0.14,
            top: h * 0.68,
            child: _TinyArc(color: Colors.white.withValues(alpha: 0.45), size: 14),
          ),
          // Top-center-left sparkle
          Positioned(
            left: w * 0.22,
            top: h * 0.06,
            child: _StarIcon(color: Colors.white.withValues(alpha: 0.5), size: 12),
          ),
          // Top-center-right dot
          _dot(right: w * 0.22, top: h * 0.14, size: 5, color: _kGold.withValues(alpha: 0.7)),
          // Lower-right sparkle
          Positioned(
            right: w * 0.10,
            top: h * 0.60,
            child: _StarIcon(color: _kGold.withValues(alpha: 0.7), size: 13),
          ),
        ],
      );
    });
  }

  Widget _dot({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required Color color,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

// ─── Tiny curved arc drawn with CustomPaint ───────────────────────────────────
class _TinyArc extends StatelessWidget {
  final Color color;
  final double size;

  const _TinyArc({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ArcPainter(color: color),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;

  _ArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -math.pi * 0.9,
      math.pi * 1.1,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}

// ─── Tiny 4-point star icon ───────────────────────────────────────────────────
class _StarIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _StarIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(color: color),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;

  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final ri = r * 0.35; // inner radius

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 2;
      final radius = i.isEven ? r : ri;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}
