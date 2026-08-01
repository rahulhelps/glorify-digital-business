import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/core/constants/app_strings.dart';

class PrivacyCheckbox extends StatefulWidget {
  final ValueChanged<bool> onChanged;

  const PrivacyCheckbox({super.key, required this.onChanged});

  @override
  State<PrivacyCheckbox> createState() => _PrivacyCheckboxState();
}

class _PrivacyCheckboxState extends State<PrivacyCheckbox> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _checked,
            onChanged: (v) {
              setState(() => _checked = v ?? false);
              widget.onChanged(_checked);
            },
            activeColor: AppColors.secondaryContainer,
            checkColor: Colors.black, // আপনার থিম অনুযায়ী চাইলে এটি Colors.white করে দেখতে পারেন
            side: WidgetStateBorderSide.resolveWith(
                  (states) {
                if (states.contains(WidgetState.selected)) {
                  return const BorderSide(
                    color: AppColors.secondaryContainer,
                    width: 1.5,
                  );
                }
                return const BorderSide(color: Colors.black54, width: 1.5);
              },
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacingSm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.43,
                  color: Colors.black87, // 🛠️ ফিক্স: সাদা ব্যাকগ্রাউন্ডে দৃশ্যমান করার জন্য ডার্ক কালার
                ),
                children: [
                  const TextSpan(text: AppStrings.privacyPrefix),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        AppStrings.privacyLink,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.43,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600, // 🛠️ লিংকটি আরেকটু স্পষ্ট করার জন্য
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: AppStrings.privacySuffix),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    //   Row(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     SizedBox(
    //       width: 20,
    //       height: 20,
    //       child: Checkbox(
    //
    //         value: _checked,
    //         onChanged: (v) {
    //           setState(() => _checked = v ?? false);
    //           widget.onChanged(_checked);
    //         },
    //         activeColor: AppColors.secondaryContainer,
    //         checkColor: Colors.black,
    //         side: WidgetStateBorderSide.resolveWith(
    //           (states) {
    //             if (states.contains(WidgetState.selected)) {
    //               return const BorderSide(
    //                 color: AppColors.secondaryContainer,
    //                 width: 1.5,
    //               );
    //             }
    //             return const BorderSide(color: Colors.black54, width: 1.5);
    //           },
    //         ),
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
    //         ),
    //       ),
    //     ),
    //     const SizedBox(width: AppSizes.spacingSm),
    //     Expanded(
    //       child: Padding(
    //         padding: const EdgeInsets.only(top: 2),
    //         child: RichText(
    //           text: TextSpan(
    //             style: const TextStyle(
    //               fontSize: 14,
    //               height: 1.43,
    //               color: AppColors.surface,
    //             ),
    //             children: [
    //               const TextSpan(text: AppStrings.privacyPrefix),
    //               WidgetSpan(
    //                 child: GestureDetector(
    //                   onTap: () {},
    //                   child: const Text(
    //                     AppStrings.privacyLink,
    //                     style: TextStyle(
    //                       fontSize: 14,
    //                       height: 1.43,
    //                       color: AppColors.secondary,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //               const TextSpan(text: AppStrings.privacySuffix),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
