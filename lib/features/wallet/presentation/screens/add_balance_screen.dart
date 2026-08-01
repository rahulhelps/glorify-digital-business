import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_payment/quick_payment.dart'; // ignore: unused_import
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_constants.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/wallet/presentation/bloc/deposit_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/deposit_event.dart';
import 'package:global_earn/features/wallet/presentation/bloc/deposit_state.dart';
import 'package:global_earn/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/features/home/presentation/screens/payment_webview_screen.dart';
import 'dart:developer' as dev;

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key});

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  final _amountController = TextEditingController();
  double _selectedAmount = 0;
  final List<double> _chips = [100, 200, 500, 1000, 2000, 5000];

  // ignore: unused_field
  String _bkashNumber = '';
  // ignore: unused_field
  String _nagadNumber = '';
  // ignore: unused_field
  String _rocketNumber = '';
  bool _isLoadingNumbers = true;
  bool _isLoadingLimits = true;
  int _minDeposit = 100;
  int _maxDeposit = 25000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPaymentNumbers();
      _fetchAppLimits();
    });
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
          _minDeposit = int.tryParse(data['minDeposit']?.toString() ?? '') ?? 100;
          _maxDeposit = int.tryParse(data['maxDeposit']?.toString() ?? '') ?? 25000;
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
        _minDeposit = 100;
        _maxDeposit = 25000;
        _isLoadingLimits = false;
      });
    }
  }

  Future<void> _fetchPaymentNumbers() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('payment_gateways')
          .doc('active_numbers')
          .get();
      
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _bkashNumber = data['bkash'] as String? ?? AppConstants.bkashNumber;
          _nagadNumber = data['nagad'] as String? ?? AppConstants.nagadNumber;
          _rocketNumber = data['rocket'] as String? ?? AppConstants.rocketNumber;
          _isLoadingNumbers = false;
        });
      } else {
        _setFallbackNumbers();
      }
    } catch (e) {
      _setFallbackNumbers();
    }
  }

  void _setFallbackNumbers() {
    if (mounted) {
      setState(() {
        _bkashNumber = AppConstants.bkashNumber;
        _nagadNumber = AppConstants.nagadNumber;
        _rocketNumber = AppConstants.rocketNumber;
        _isLoadingNumbers = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onChipSelected(double amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toInt().toString();
    });
  }

  void _onAmountChanged(String value) {
    setState(() {
      _selectedAmount = double.tryParse(value) ?? 0;
    });
  }

  void _processPayment(BuildContext context, user) {
    if (_selectedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে এমাউন্ট লিখুন')),
      );
      return;
    }

    if (_selectedAmount < _minDeposit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ডিপোজিট করার নূন্যতম পরিমাণ হলো ৳$_minDeposit')),
      );
      return;
    }

    if (_selectedAmount > _maxDeposit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ডিপোজিট করার সর্বোচ্চ পরিমাণ হলো ৳$_maxDeposit')),
      );
      return;
    }

    // OLD MANUAL DEPOSIT SYSTEM — DISABLED. Replaced by automatic ZiniPay flow.
    // Do NOT delete — kept for reference / rollback capability.
    /*
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    QuickPay.createPayment(
      context: context,
      amount: _selectedAmount.toInt(),
      customer: CustomerDetails(fullName: user.name, email: user.email),
      credentials: QuickPayCredentials(
        feePercentage: 2.0,
        methods: [
          PaymentMethod.bkash(_bkashNumber),
          PaymentMethod.nagad(_nagadNumber),
          PaymentMethod.rocket(_rocketNumber),
        ],
      ),
      supportCredentials: QuickPaySupportCredentials(
        email: AppConstants.supportEmail,
        phoneNumber: AppConstants.supportPhone,
      ),
      onPaymentSubmitted: (data) async {
        context.read<DepositBloc>().add(
          SubmitDeposit(
            amount: data.amount.toDouble(),
            method: data.method.toString(),
            transactionId: data.transactionId,
            submittedAt: data.time,
            uid: user.uid,
            userName: user.name,
            userEmail: user.email,
          ),
        );
      },
    );
    */

    context.read<DepositBloc>().add(
      AutoDepositRequested(uid: user.uid, amount: _selectedAmount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DepositBloc>(),
      child: BlocConsumer<DepositBloc, DepositState>(
        listener: (context, state) {
          if (state is DepositSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'পেমেন্ট সাবমিট হয়েছে! অনুমোদনের জন্য অপেক্ষা করুন',
                ),
              ),
            );
          } else if (state is DepositError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AutoDepositUrlReady) {
            dev.log('🔥 [Deposit] Navigating to PaymentWebViewScreen with url: ${state.paymentUrl}');
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<DepositBloc>(),
                  child: PaymentWebViewScreen(
                    paymentUrl: state.paymentUrl,
                    invoiceCollectionPath: 'deposit_invoices',
                  ),
                ),
              ),
            );
          } else if (state is AutoDepositError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting =
              state is DepositSubmitting || state is DepositSubmitted || state is AutoDepositLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: const Text(
                'ব্যালেন্স যোগ করুন',
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go('/home'),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.white),
                  onPressed: () => context.push('/wallet/deposit-history'),
                ),
              ],
            ),
            body: BlocBuilder<UserBloc, UserState>(
              buildWhen: (previous, current) => previous != current,
              builder: (context, userState) {
                if (userState is! UserLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = userState.user;
                final balanceDisplay = user.withdrawableBalance;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current Balance Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'বর্তমান ব্যালেন্স',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '৳ ${balanceDisplay.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'এমাউন্ট নির্বাচন করুন',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chips
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _chips.map((amount) {
                          final isSelected = _selectedAmount == amount;
                          return GestureDetector(
                            onTap: () => _onChipSelected(amount),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.outline,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                '৳${amount.toInt()}',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Custom Amount TextField
                      TextField(
                        controller: _amountController,
                        onChanged: _onAmountChanged,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'অন্যান্য এমাউন্ট লিখুন',
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          prefixText: '৳ ',
                          prefixStyle: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.outline,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (!_isLoadingLimits)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'নূন্যতম ডিপোজিট ৳$_minDeposit এবং সর্বোচ্চ ডিপোজিট ৳$_maxDeposit',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Payment Button
                      ElevatedButton(
                        onPressed: (isSubmitting || _isLoadingNumbers || _isLoadingLimits)
                            ? null
                            : () => _processPayment(context, user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoadingNumbers
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isSubmitting ? 'পর্যালোচনাধীন...' : 'পেমেন্ট করুন',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
