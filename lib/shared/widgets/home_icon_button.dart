import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeIconButton extends StatefulWidget {
  final dynamic icon;
  final String label;
  final Color gradientStart;
  final Color gradientEnd;
  final Color pastelBg;
  final VoidCallback onTap;

  const HomeIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.gradientStart,
    required this.gradientEnd,
    required this.pastelBg,
    required this.onTap,
  });

  @override
  State<HomeIconButton> createState() => _HomeIconButtonState();
}

class _HomeIconButtonState extends State<HomeIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: widget.icon is String
                    ? Image.asset(
                        widget.icon as String,
                        width: 55,
                        height: 55,
                        fit: BoxFit.contain,
                      )
                    : FaIcon(
                        widget.icon as IconData,
                        color: widget.gradientStart,
                        size: 30,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
    );
  }
}


// Container(
// padding: const EdgeInsets.all(10),
// decoration: BoxDecoration(
// color: Colors.white,
// borderRadius: BorderRadius.circular(16),
// boxShadow: [
// BoxShadow(
// color: Colors.deepOrange.withOpacity(0.05),
// blurRadius: 10,
// spreadRadius: 0,
// offset: const Offset(0, 4),
// ),
// ],
// ),
// child:
