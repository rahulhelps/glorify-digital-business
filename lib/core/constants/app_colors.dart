import 'package:flutter/material.dart';

abstract class AppColors {
  // Background
  static const background = Color(0xFFF5F5F5);
  static const surfaceDim = Color(0xFFEEEEEE);
  static const surfaceContainer = Color(0xFFFFFFFF);
  static const surfaceContainerHigh = Color(0xFFF5F5F5);
  static const surfaceContainerHighest = Color(0xFFE0E0E0);
  static const card = Color(0xFFFFFFFF);

  // Brand gradient endpoints
  static const coral = Color(0xFF1976D2); // Sky blue (primary)
  static const cyan = Color(0xFF0A1A4A); // Deep navy (primary dark)
  static const primary = cyan;
  static const primaryDark = coral;
  static const primaryContainer = Color(0xFF1565C0);

  // Primary gradient: sky blue → deep navy (top to bottom)
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF123875), Color(0xFF0A1A4A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const surfaceContainerLowest = Color(0xFF0E0E0E);

  // Text
  static const onSurface = Color(0xFF1A1A1A);
  static const onSurfaceVariant = Color(0xFF757575);
  static const textPrimary = onSurface;
  static const textSecondary = onSurfaceVariant;

  // Secondary
  static const secondary = Color(0xFF00CED1);
  static const secondaryContainer = Color(0xFFE0F7FA);

  // Outline
  static const outline = Color(0xFFE0E0E0);
  static const outlineVariant = Color(0xFFBDBDBD);

  // Footer
  static const footerBg = coral;

  // Bottom nav shell
  static const navBarBg = Color(0xFFFFFFFF);

  // Secondary fixed dim (icon tint in login)
  static const secondaryFixedDim = Color(0xFF00838F);

  // Utility
  static const white10 = Color(0x1A000000);
  static const white20 = Color(0x33000000);
  static const white30 = Color(0x4D000000);
  static const white60 = Color(0x99000000);
  static const white70 = Color(0xB3000000);
  static const white80 = Color(0xCC000000);
  static const white = Color(0xFFFFFFFF);
  static const error = Color(0xFFD32F2F);
  static const errorContainer = Color(0xFF93000A);
  static const success = Color(0xFF388E3C);
  static const star = Color(0xFFFFC107);
  static const shadowSubtle = Color(0x1F000000);

  // Background accent blobs (login screen)
  static const indigoBlob = Color(0xFF2E3192);

  // Wallet screen
  static const neutral500 = Color(0xFF757575);

  // Network screen
  static const primaryLight = Color(0xFFFFB59C);
  static const inverseOnSurface = Color(0xFFFFFFFF);
  static const onPrimaryFixedVariant = Color(0xFF822800);
  static const onTertiaryFixedVariant = Color(0xFF373A9B);
  static const secondaryFixed = Color(0xFF00CED1);

  // Course screen
  static const courseBackground = Color(0xFFF3F4F6);
  static const surface = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF1A1A1A);
  static const gold = Color(0xFFFFD700);
}
