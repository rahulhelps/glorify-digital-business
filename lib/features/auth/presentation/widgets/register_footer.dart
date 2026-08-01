import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/core/constants/app_strings.dart';

/// Premium footer matching the deep-navy AppBar gradient system.
class RegisterFooter extends StatelessWidget {
  const RegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.footerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF061529), Color(0xFF0A2040)],
        ),
        border: Border(
          top: BorderSide(color: Color(0x2200CED1)),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        AppStrings.footerText,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white30,
          letterSpacing: 0.8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
