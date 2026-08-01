import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium gradient CTA button used across Login and Register screens.
///
/// Design:
///  • Sapphire → cyan gradient fill
///  • Soft cyan bottom-glow shadow (elevation simulation)
///  • Subtle white top-edge highlight for 3D depth
///  • Google Fonts Inter for crisp, modern label typography
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1565C0), // deep sapphire
              Color(0xFF1E90FF), // bright blue
              Color(0xFF00CED1), // cyan highlight
            ],
          ),
          boxShadow: const [
            // Cyan bottom glow
            BoxShadow(
              color: Color(0x5500CED1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 6),
            ),
            // Darker base shadow for elevation feel
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              // Subtle white top highlight border for 3D depth
              side: const BorderSide(
                color: Color(0x22FFFFFF),
                width: 1,
              ),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
        ),
      ),
    );
  }
}
