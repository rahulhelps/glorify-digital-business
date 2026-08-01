import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';

class SnackbarUtils {
  static void showComingSoonSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.access_time_filled, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'এই ফিচারটির কাজ চলছে, খুব শীঘ্রই যুক্ত হবে।',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
