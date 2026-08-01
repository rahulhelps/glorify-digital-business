import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

class FloatingContactButtons extends StatelessWidget {
  const FloatingContactButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ContactFab(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0088CC), Color(0xFF22AADD)],
          ),
          icon: Icons.telegram,
          onTap: () {},
        ),
        const SizedBox(height: AppSizes.spacingMd),
        _ContactFab(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0084FF), Color(0xFF00C6FF)],
          ),
          icon: Icons.message_rounded,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ContactFab extends StatefulWidget {
  final LinearGradient gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _ContactFab({
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_ContactFab> createState() => _ContactFabState();
}

class _ContactFabState extends State<_ContactFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: AppSizes.fabSize,
          height: AppSizes.fabSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.gradient,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: AppSizes.fabIconSize,
          ),
        ),
      ),
    );
  }
}
