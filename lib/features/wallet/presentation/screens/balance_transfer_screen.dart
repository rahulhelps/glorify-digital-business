import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_event.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_state.dart';
import 'package:global_earn/features/wallet/presentation/widgets/transfer_user_lookup.dart';
import 'package:global_earn/features/wallet/presentation/widgets/transfer_details_form.dart';
import 'package:global_earn/features/wallet/presentation/widgets/transfer_action_button.dart';
import 'package:global_earn/service_locator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:global_earn/shared/widgets/verification_guard.dart';

class BalanceTransferScreen extends StatefulWidget {
  const BalanceTransferScreen({super.key});

  @override
  State<BalanceTransferScreen> createState() => _BalanceTransferScreenState();
}

class _BalanceTransferScreenState extends State<BalanceTransferScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _enteredPin = '';
  double _totalBalance = 0.0;

  bool get _isFormValid {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final isValid = amount >= 100 &&
        amount <= _totalBalance &&
        _enteredPin.length == 4;
    debugPrint('🔥 [TransferScreen] isValid: $isValid, amount: $amount, '
        'balance: $_totalBalance, pin: ${_enteredPin.length}');
    return isValid;
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showPinNotSetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'পিন সেট করুন',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'ট্রান্সফার করতে আগে পিন সেট করতে হবে',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'বাতিল',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/change-pin');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'পিন সেট করুন',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    double amount,
    String receiverName,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'সফল হয়েছে!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '৳$amount সফলভাবে ট্রান্সফার হয়েছে $receiverName এর কাছে',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
                child: const Text(
                  'ঠিক আছে',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    if (userState is! UserLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _totalBalance = userState.user.withdrawableBalance;
    final currentUser = userState.user;

    return BlocProvider(
      create: (context) => sl<TransferBloc>(),
      child: BlocConsumer<TransferBloc, TransferState>(
        listenWhen: (previous, current) =>
            current.status == TransferStatus.error ||
            current.status == TransferStatus.success ||
            current.status == TransferStatus.pinNotSet,
        listener: (context, state) {
          if (state.status == TransferStatus.success) {
            _amountController.clear();
            _enteredPin = '';
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ট্রান্সফার সফল হয়েছে'),
                backgroundColor: Colors.green,
              ),
            );
            _showSuccessDialog(context, state.amount ?? 0.0, state.receiverName ?? '');
          } else if (state.status == TransferStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'ত্রুটি হয়েছে'),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status == TransferStatus.pinNotSet) {
            _showPinNotSetDialog(context);
          }
        },
        // Removed buildWhen here so that typing in the amount or PIN
        // correctly rebuilds the widget tree and updates the button.
        builder: (context, state) {
            final hasReceiver = state.receiver != null;
            final isEnabled = hasReceiver && _isFormValid && !state.isLoading;

            debugPrint('🔥 [TransferButton] hasReceiver: $hasReceiver, '
                'formValid: $_isFormValid, loading: ${state.isLoading}, '
                'enabled: $isEnabled');

            return VerificationGuard(
              child: Scaffold(
                backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.primary,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                title: const Text(
                  'ব্যালেন্স ট্রান্সফার',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              bottomNavigationBar: TransferActionButton(
                isEnabled: isEnabled,
                isLoading: state.isLoading,
                onPressed: () {
                  final amountToTransfer = double.tryParse(_amountController.text.trim()) ?? 0.0;
                  debugPrint('🔥 [Transfer] Button tapped — amount: $amountToTransfer, pin: $_enteredPin');

                  context.read<TransferBloc>().add(
                    SubmitTransfer(
                      amount: amountToTransfer,
                      pin: _enteredPin,
                      sender: currentUser,
                      receiver: state.receiver!,
                    ),
                  );
                },
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.marginMobile,
                  vertical: AppSizes.spacingLg,
                ),
                child: Column(
                  children: [
                    TransferUserLookup(
                      controller: _searchController,
                      currentUid: currentUser.uid,
                    ),
                    const SizedBox(height: AppSizes.spacingLg),
                    TransferDetailsForm(
                      amountController: _amountController,
                      totalBalance: currentUser.withdrawableBalance,
                      onTransferAll: () {
                        _amountController.text = currentUser.withdrawableBalance.toStringAsFixed(0);
                      },
                      onPinComplete: (pin) {
                        setState(() {
                          _enteredPin = pin;
                        });
                        debugPrint('✅ [TransferScreen] PIN complete: $pin');
                      },
                      onPinChanged: (pin) {
                        setState(() {
                          _enteredPin = pin;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ));
          },
        ),
    );
  }
}
