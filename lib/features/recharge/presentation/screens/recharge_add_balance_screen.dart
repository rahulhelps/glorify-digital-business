import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_bloc.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_event.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_state.dart';

class RechargeAddBalanceScreen extends StatefulWidget {
  const RechargeAddBalanceScreen({super.key});

  @override
  State<RechargeAddBalanceScreen> createState() =>
      _RechargeAddBalanceScreenState();
}

class _RechargeAddBalanceScreenState extends State<RechargeAddBalanceScreen> {
  final _transferController = TextEditingController();
  double _transferAmount = 0;

  @override
  void initState() {
    super.initState();
    _transferController.addListener(() {
      final amount = double.tryParse(_transferController.text.trim()) ?? 0;
      setState(() {
        _transferAmount = amount;
      });
    });
  }

  @override
  void dispose() {
    _transferController.dispose();
    super.dispose();
  }

  void _doTransfer(BuildContext context, String uid, double mainBalance) {
    if (_transferAmount < 20) {
      _showError(context, 'সর্বনিম্ন পরিমাণ ৳২০');
      return;
    }
    if (_transferAmount > mainBalance) {
      _showError(context, 'পর্যাপ্ত মেইন ব্যালেন্স নেই');
      return;
    }
    context.read<RechargeBloc>().add(
          TransferFromWallet(
            uid: uid,
            amount: _transferAmount,
            currentMainBalance: mainBalance,
          ),
        );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RechargeBloc, RechargeState>(
      listenWhen: (prev, curr) =>
          curr is RechargeSubmitted || curr is RechargeError,
      listener: (context, state) {
        if (state is RechargeSubmitted) {
          _transferController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else if (state is RechargeError) {
          _showError(context, state.message);
        }
      },
      builder: (context, rechargeState) {
        final bool isSubmitting = rechargeState is RechargeSubmitting;

        return BlocBuilder<UserBloc, UserState>(
          buildWhen: (p, c) => p != c,
          builder: (context, userState) {
            if (userState is! UserLoaded) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            final user = userState.user;
            final double mainBalance = user.withdrawableBalance;

            return Scaffold(
              backgroundColor: const Color(0xFFF0F4F8),
              appBar: AppBar(
                backgroundColor: AppColors.primary,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'রিচার্জ ব্যালেন্স যোগ করুন',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              body: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                  double dynamicMainBalance = mainBalance;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    final balanceMap = data?['balance'] as Map<String, dynamic>?;
                    if (balanceMap != null) {
                      final earning = (balanceMap['earning'] as num?)?.toDouble() ?? 0.0;
                      final voucher = (balanceMap['voucher'] as num?)?.toDouble() ?? 0.0;
                      final referral = (balanceMap['referral'] as num?)?.toDouble() ?? 0.0;
                      dynamicMainBalance = earning + voucher + referral;
                    }
                  }
                  return _WalletTransferTab(
                    mainBalance: dynamicMainBalance,
                    controller: _transferController,
                    transferAmount: _transferAmount,
                    isSubmitting: isSubmitting,
                    onTransfer: () =>
                        _doTransfer(context, user.uid, dynamicMainBalance),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _WalletTransferTab extends StatelessWidget {
  final double mainBalance;
  final TextEditingController controller;
  final double transferAmount;
  final bool isSubmitting;
  final VoidCallback onTransfer;

  const _WalletTransferTab({
    required this.mainBalance,
    required this.controller,
    required this.transferAmount,
    required this.isSubmitting,
    required this.onTransfer,
  });

  bool get _isValid => transferAmount >= 20 && transferAmount <= mainBalance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current main balance card
          _BalanceInfoCard(
            label: 'মেইন ওয়ালেট ব্যালেন্স',
            balance: mainBalance,
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 8),
          // Arrow indicator
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_downward_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 8),
          _BalanceInfoCard(
            label: 'রিচার্জ ওয়ালেট (গন্তব্য)',
            balance: null,
            icon: Icons.phone_android_rounded,
            isDestination: true,
          ),
          const SizedBox(height: 20),

          // Amount input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ট্রান্সফার পরিমাণ',
                  style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'পরিমাণ লিখুন',
                    hintStyle: GoogleFonts.manrope(
                        color: AppColors.textSecondary, fontSize: 14),
                    prefixText: '৳ ',
                    prefixStyle: GoogleFonts.manrope(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                            color: AppColors.primary, width: 2.0)),
                  ),
                ),
                if (transferAmount > 0 && transferAmount < 20)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'সর্বনিম্ন পরিমাণ ৳২০',
                      style: GoogleFonts.manrope(
                          fontSize: 12, color: AppColors.error),
                    ),
                  )
                else if (transferAmount > mainBalance && mainBalance >= 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'পর্যাপ্ত ব্যালেন্স নেই',
                      style: GoogleFonts.manrope(
                          fontSize: 12, color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_isValid && !isSubmitting) ? onTransfer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.swap_horiz_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text('ট্রান্সফার করুন',
                            style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceInfoCard extends StatelessWidget {
  final String label;
  final double? balance;
  final IconData icon;
  final bool isDestination;

  const _BalanceInfoCard({
    required this.label,
    required this.balance,
    required this.icon,
    this.isDestination = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDestination
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (balance != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '৳${balance!.toStringAsFixed(2)}',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isDestination)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '0% Fee',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
