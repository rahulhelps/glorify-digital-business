import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/delete_account/presentation/bloc/delete_account_bloc.dart';
import 'package:global_earn/features/delete_account/presentation/bloc/delete_account_event.dart';
import 'package:global_earn/features/delete_account/presentation/bloc/delete_account_state.dart';

class ConfirmationCheckbox extends StatelessWidget {
  const ConfirmationCheckbox({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteAccountBloc, DeleteAccountState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return InkWell(
          onTap: () {
            context.read<DeleteAccountBloc>().add(
              ToggleConfirmation(!state.isConfirmed),
            );
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: state.isConfirmed,
                  onChanged: (val) {
                    context.read<DeleteAccountBloc>().add(
                      ToggleConfirmation(val ?? false),
                    );
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMd),
                Expanded(
                  child: Text(
                    'আমি বুঝতে পেরেছি এবং একাউন্ট ডিলিট করতে চাই',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
