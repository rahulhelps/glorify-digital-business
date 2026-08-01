import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/change_password/presentation/bloc/change_password_bloc.dart';
import 'package:global_earn/features/change_password/presentation/bloc/change_password_state.dart';
import 'package:global_earn/features/change_password/presentation/widgets/change_password_action_buttons.dart';
import 'package:global_earn/features/change_password/presentation/widgets/change_password_form.dart';
import 'package:global_earn/features/change_password/presentation/widgets/change_password_header.dart';
import 'package:global_earn/service_locator.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChangePasswordBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.coral,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
        ),
        body: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
          listener: (context, state) {
            if (state is ChangePasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে'),
                  backgroundColor: AppColors.success,
                ),
              );
              // Fix 1: Improved navigation
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            } else if (state is ChangePasswordError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile,
                vertical: AppSizes.spacingLg,
              ),
              child: Column(
                children: [
                  const ChangePasswordHeader(),
                  const SizedBox(height: AppSizes.spacingXl),
                  ChangePasswordForm(
                    currentController: currentController,
                    newController: newController,
                    confirmController: confirmController,
                  ),
                  const SizedBox(height: 48),
                  // Fix: Remove screen-level spinner, button handles it now
                  ChangePasswordActionButtons(
                    currentController: currentController,
                    newController: newController,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
