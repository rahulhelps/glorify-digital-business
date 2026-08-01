import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/wallet/presentation/bloc/withdraw_bloc.dart';
import 'package:global_earn/features/wallet/presentation/widgets/withdraw_balance_summary.dart';
import 'package:global_earn/features/wallet/presentation/widgets/payment_method_grid.dart';
import 'package:global_earn/features/wallet/presentation/widgets/withdraw_input_fields.dart';
import 'package:global_earn/features/wallet/presentation/widgets/withdraw_info_cards.dart';
import 'package:global_earn/features/wallet/presentation/widgets/withdraw_bottom_action.dart';
import 'package:global_earn/features/wallet/presentation/widgets/withdrawal_success_dialog.dart';
import 'package:global_earn/service_locator.dart';
import 'package:global_earn/shared/widgets/verification_guard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawBalanceScreen extends StatefulWidget {
  const WithdrawBalanceScreen({super.key});

  @override
  State<WithdrawBalanceScreen> createState() => _WithdrawBalanceScreenState();
}

class _WithdrawBalanceScreenState extends State<WithdrawBalanceScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  // Tracks the last submitted amount so we can show it in the success dialog
  double _lastSubmittedAmount = 0;

  int _minWithdrawal = 100;
  int _maxWithdrawal = 10000;
  int _firstTimeWithdrawal = 20;
  bool _isLoadingLimits = true;

  @override
  void initState() {
    super.initState();
    _fetchAppLimits();
  }

  Future<void> _fetchAppLimits() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('app_limits')
          .get();
      
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _minWithdrawal = int.tryParse(data['minWithdrawal']?.toString() ?? '') ?? 100;
          _maxWithdrawal = int.tryParse(data['maxWithdrawal']?.toString() ?? '') ?? 10000;
          _firstTimeWithdrawal = int.tryParse(data['firstTimeWithdrawal']?.toString() ?? '') ?? 20;
          _isLoadingLimits = false;
        });
      } else {
        _setFallbackLimits();
      }
    } catch (e) {
      _setFallbackLimits();
    }
  }

  void _setFallbackLimits() {
    if (mounted) {
      setState(() {
        _minWithdrawal = 100;
        _maxWithdrawal = 10000;
        _firstTimeWithdrawal = 20;
        _isLoadingLimits = false;
      });
    }
  }

  void _onMethodSelected(BuildContext context, String method) {
    context.read<WithdrawBloc>().add(SelectPaymentMethod(method));
  }

  void _submitWithdraw(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoaded) return;

    final user = userState.user;
    final earning = user.balance.earning.toDouble();
    final voucher = user.balance.voucher.toDouble();
    final referral = user.balance.referral.toDouble();
    final maxWithdrawable = user.withdrawableBalance;

    final accountNumber = _accountController.text.trim();
    final amountText = _amountController.text.trim();

    final withdrawState = context.read<WithdrawBloc>().state;
    final selectedMethod = withdrawState.selectedMethod;
    final bankName = _bankNameController.text.trim();

    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('পেমেন্ট মেথড নির্বাচন করুন')),
      );
      return;
    }

    if (selectedMethod == 'Bank' && bankName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ব্যাংকের নাম দিন')));
      return;
    }

    if (accountNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('একাউন্ট নম্বর দিন')));
      return;
    }

    if (accountNumber.length < 11 && selectedMethod != 'Bank') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সঠিক একাউন্ট নম্বর দিন (কমপক্ষে ১১ সংখ্যা)'),
        ),
      );
      return;
    }

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('উত্তোলনের পরিমাণ লিখুন')));
      return;
    }

    final amount = double.tryParse(amountText) ?? 0;

    final minimumAmount = user.hasWithdrawnBefore ? _minWithdrawal.toDouble() : _firstTimeWithdrawal.toDouble();

    if (amount < minimumAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.hasWithdrawnBefore
                ? 'সর্বনিম্ন উত্তোলন ৳$_minWithdrawal'
                : 'সর্বনিম্ন উত্তোলন ৳$_firstTimeWithdrawal (প্রথমবার বিশেষ সুবিধা)',
          ),
        ),
      );
      return;
    }

    if (amount > maxWithdrawable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'অপর্যাপ্ত ব্যালেন্স। সর্বোচ্চ ৳$maxWithdrawable উত্তোলন করতে পারবেন',
          ),
        ),
      );
      return;
    }

    if (amount > _maxWithdrawal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'একবারে সর্বোচ্চ ৳$_maxWithdrawal উত্তোলন করতে পারবেন',
          ),
        ),
      );
      return;
    }

    _lastSubmittedAmount = amount;

    context.read<WithdrawBloc>().add(
      SubmitWithdraw(
        method: selectedMethod,
        accountNumber: accountNumber,
        amount: amount,
        uid: user.uid,
        userName: user.name,
        earning: earning,
        voucher: voucher,
        referral: referral,
        bankName: selectedMethod == 'Bank' ? bankName : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<WithdrawBloc>(),
      child: BlocListener<WithdrawBloc, WithdrawState>(
        listener: (context, state) {
          if (state is WithdrawSuccess) {
            final now = DateTime.now();
            final paymentMethod =
                state.selectedMethod ?? 'N/A';
            final userState = context.read<UserBloc>().state;
            final userPhone =
                userState is UserLoaded ? userState.user.phone : '';

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => WithdrawalSuccessDialog(
                amount: _lastSubmittedAmount,
                paymentMethod: paymentMethod,
                userPhone: userPhone,
                dateTime: now,
              ),
            ).then((_) => context.pop());
          } else if (state is WithdrawError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Builder(
          builder: (context) {
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
                  'ব্যালেন্স উত্তোলন',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              bottomNavigationBar: WithdrawBottomAction(
                onPressed: _isLoadingLimits ? null : () => _submitWithdraw(context),
              ),
              body: BlocBuilder<UserBloc, UserState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, userState) {
                  if (userState is! UserLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final user = userState.user;
                  return BlocBuilder<WithdrawBloc, WithdrawState>(
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, withdrawState) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.marginMobile,
                          AppSizes.spacingLg,
                          AppSizes.marginMobile,
                          AppSizes.spacingXl,
                        ),
                        child: Column(
                          children: [
                            WithdrawBalanceSummary(user: user),
                            const SizedBox(height: AppSizes.spacingLg),
                            PaymentMethodGrid(
                              selectedMethod: withdrawState.selectedMethod,
                              onMethodSelected: (method) =>
                                  _onMethodSelected(context, method),
                            ),
                            const SizedBox(height: AppSizes.spacingLg),
                            WithdrawInputFields(
                              accountController: _accountController,
                              amountController: _amountController,
                              bankNameController: _bankNameController,
                              selectedMethod: withdrawState.selectedMethod,
                              user: user,
                              minWithdrawal: _minWithdrawal,
                              maxWithdrawal: _maxWithdrawal,
                              firstTimeWithdrawal: _firstTimeWithdrawal,
                            ),
                            const SizedBox(height: AppSizes.spacingLg),
                            if (withdrawState.inputAmount > 0) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2022),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.secondary.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.shadowSubtle,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'উত্তোলন চার্জ (৩%): ৳${withdrawState.feeAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'আপনি পাবেন (Net Balance): ৳${withdrawState.payableAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSizes.spacingLg),
                            ],
                            const WithdrawInfoCards(),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ));
          },
        ),
      ),
    );
  }
}
