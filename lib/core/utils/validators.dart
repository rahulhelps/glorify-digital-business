import 'package:global_earn/core/constants/app_strings.dart';

abstract class Validators {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    return null;
  }

  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return AppStrings.invalidMobile;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    if (value.length < 6) return AppStrings.passwordTooShort;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    if (value != original) return AppStrings.passwordMismatch;
    return null;
  }

  static String? mobileOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final isMobile = digits.length >= 10;
    final isEmail = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$').hasMatch(value.trim());
    if (!isMobile && !isEmail) return AppStrings.invalidMobileOrEmail;
    return null;
  }
}
