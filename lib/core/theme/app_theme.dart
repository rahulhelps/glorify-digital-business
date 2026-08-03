import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';

abstract class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surfaceDim,
        primary: AppColors.coral,
        secondary: AppColors.secondary,
        error: AppColors.error,
        onSurface: AppColors.onSurface,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            headlineLarge: GoogleFonts.manrope(
              fontSize: 32,
              height: 40 / 32,
              letterSpacing: -0.02 * 32,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
            headlineMedium: GoogleFonts.manrope(
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurface,
            ),
            bodySmall: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurface,
            ),
            labelLarge: GoogleFonts.inter(
              fontSize: 14,
              height: 16 / 14,
              letterSpacing: 0.05 * 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
      useMaterial3: true,
    );
  }
}
