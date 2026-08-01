// Shared premium-guard dialog — extracted from micro_job_panel_screen.dart
// Use showPremiumRequiredDialog() inside initState via addPostFrameCallback
// whenever you need to block non-premium users with the same UI as Micro Job.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';

// void showPremiumRequiredDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       backgroundColor: AppColors.surface,
//       title: const Row(
//         children: [
//           Icon(Icons.star_rounded, color: AppColors.primary),
//           SizedBox(width: 8),
//           Text(
//             'প্রিমিয়াম প্রয়োজন',
//             style: TextStyle(
//               color: AppColors.textPrimary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       content: const Text(
//         'এই ফিচারটি ব্যবহার করতে প্রিমিয়াম সদস্যপদ প্রয়োজন। প্রিমিয়াম নিন এবং সমস্ত সুবিধা উপভোগ করুন।',
//         style: TextStyle(color: AppColors.textSecondary),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//             if (context.canPop()) {
//               context.pop();
//             } else {
//               context.go('/home');
//             }
//           },
//           child: const Text(
//             'ফিরে যান',
//             style: TextStyle(color: AppColors.textSecondary),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             Navigator.pop(context);
//             context.go('/home');
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primary,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 0,
//           ),
//           child: const Text(
//             'প্রিমিয়াম নিন',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ],
//     ),
//   );
// }


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showPremiumRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.transparent, // ভেতরের কন্টেইনার যেন সঠিকভাবে রাউন্ডেড শেপ পায়
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface, // আপনার অ্যাপের সারফেস কালার
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // কন্টেন্ট অনুযায়ী সাইজ নেবে
          children: [
            // Top Blue Header (স্ক্রিনশটের মতো উপরের ব্লু অংশ)
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.primary, // আপনার অ্যাপের প্রাইমারি কালার
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  // Title Text
                  const Text(
                    'দুঃখিত',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary, // আপনার অ্যাপের টেক্সট কালার
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Description Text
                  const Text(
                    'আপনার একাউন্ট ভেরিফাই নয়',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary, // আপনার অ্যাপের সেকেন্ডারি টেক্সট কালার
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Primary Button (ভেরিফাই করুন)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // আপনার আগের 'প্রিমিয়াম নিন' বাটনের লজিক
                        Navigator.pop(context);
                        context.go('/home');
                      },
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'ভেরিফাই করুন',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Secondary Button (পরে করব)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // আপনার আগের 'ফিরে যান' বাটনের লজিক
                        Navigator.pop(context);
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDE3730), // প্রফেশনাল রেড কালার
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'পরে করব',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}