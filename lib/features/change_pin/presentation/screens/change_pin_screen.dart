import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/change_pin/presentation/bloc/change_pin_bloc.dart';
import 'package:global_earn/features/change_pin/presentation/bloc/change_pin_event.dart';
import 'package:global_earn/features/change_pin/presentation/bloc/change_pin_state.dart';
import 'package:global_earn/features/change_pin/presentation/widgets/change_pin_hero.dart';
import 'package:global_earn/features/change_pin/presentation/widgets/pin_input_section.dart';
import 'package:global_earn/service_locator.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final List<TextEditingController> _currentPinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _currentPinFocusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );

  final List<TextEditingController> _newPinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _newPinFocusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );

  final List<TextEditingController> _confirmPinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _confirmPinFocusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = context.read<UserBloc>().state;
      if (userState is UserLoaded) {
        context.read<ChangePinBloc>().add(LoadPinStatus(userState.user.uid));
      }
    });
  }

  @override
  void dispose() {
    for (var controller in [
      ..._currentPinControllers,
      ..._newPinControllers,
      ..._confirmPinControllers,
    ]) {
      controller.dispose();
    }
    for (var node in [
      ..._currentPinFocusNodes,
      ..._newPinFocusNodes,
      ..._confirmPinFocusNodes,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  String _getPinFromControllers(List<TextEditingController> controllers) {
    return controllers.map((c) => c.text).join();
  }

  void _submit(BuildContext context, String uid, bool isAlreadySet) {
    final currentPin = _getPinFromControllers(_currentPinControllers);
    final newPin = _getPinFromControllers(_newPinControllers);
    final confirmPin = _getPinFromControllers(_confirmPinControllers);

    if (isAlreadySet && currentPin.length < 4) {
      _showError('পিন সম্পূর্ণ করুন');
      return;
    }
    if (newPin.length < 4 || confirmPin.length < 4) {
      _showError('পিন সম্পূর্ণ করুন');
      return;
    }
    if (newPin != confirmPin) {
      _showError('নতুন পিন মিলছে না');
      return;
    }

    if (isAlreadySet) {
      context.read<ChangePinBloc>().add(
        ChangePin(uid: uid, currentPin: currentPin, newPin: newPin),
      );
    } else {
      context.read<ChangePinBloc>().add(SetPin(uid: uid, newPin: newPin));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    if (userState is! UserLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final uid = userState.user.uid;

    return BlocProvider(
      create: (context) => sl<ChangePinBloc>()..add(LoadPinStatus(uid)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
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
          title: BlocBuilder<ChangePinBloc, ChangePinState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              final isAlreadySet = state is PinAlreadySet;
              return Text(
                isAlreadySet ? 'পিন পরিবর্তন করুন' : 'পিন সেট করুন',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ),
        body: BlocConsumer<ChangePinBloc, ChangePinState>(
          listener: (context, state) {
            if (state is PinSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            } else if (state is PinError) {
              _showError(state.message);
            }
          },
          builder: (context, state) {
            if (state is PinLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final isAlreadySet = state is PinAlreadySet;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile,
                vertical: AppSizes.spacingLg,
              ),
              child: Column(
                children: [
                  const ChangePinHero(),
                  const SizedBox(height: AppSizes.spacingLg),
                  if (isAlreadySet) ...[
                    PinInputSection(
                      label: 'বর্তমান পিন',
                      controllers: _currentPinControllers,
                      focusNodes: _currentPinFocusNodes,
                    ),
                    const SizedBox(height: AppSizes.spacingLg),
                  ],
                  PinInputSection(
                    label: 'নতুন পিন',
                    controllers: _newPinControllers,
                    focusNodes: _newPinFocusNodes,
                  ),
                  const SizedBox(height: AppSizes.spacingLg),
                  PinInputSection(
                    label: 'পিন নিশ্চিত করুন',
                    controllers: _confirmPinControllers,
                    focusNodes: _confirmPinFocusNodes,
                  ),
                  const SizedBox(height: AppSizes.spacingXl),
                  _buildUpdateButton(context, state, isAlreadySet, uid),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUpdateButton(
    BuildContext context,
    ChangePinState state,
    bool isAlreadySet,
    String uid,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.secondaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state is PinLoading
              ? null
              : () => _submit(context, uid, isAlreadySet),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: state is PinLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isAlreadySet ? 'পিন আপডেট করুন' : 'পিন সেট করুন',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
