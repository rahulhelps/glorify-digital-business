import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/change_pin/presentation/bloc/change_pin_bloc.dart';
import 'package:global_earn/features/change_pin/presentation/bloc/change_pin_event.dart';

class ChangePinNumpad extends StatelessWidget {
  const ChangePinNumpad({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: AppSizes.spacingMd,
      crossAxisSpacing: AppSizes.spacingMd,
      childAspectRatio: 1.5,
      children: [
        ...List.generate(
          9,
          (index) => _buildNumberButton(context, '${index + 1}'),
        ),
        const SizedBox.shrink(),
        _buildNumberButton(context, '0'),
        _buildBackspaceButton(context),
      ],
    );
  }

  Widget _buildNumberButton(BuildContext context, String digit) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<ChangePinBloc>().add(PinDigitPressed(digit)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Center(
            child: Text(
              digit,
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<ChangePinBloc>().add(PinBackspacePressed()),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDim,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
