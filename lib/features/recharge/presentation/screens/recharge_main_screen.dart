import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_bloc.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_event.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_state.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_history_bloc.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_history_event.dart';
import 'package:global_earn/features/recharge/presentation/screens/recharge_history_screen.dart';
import 'package:global_earn/service_locator.dart';

class RechargeMainScreen extends StatefulWidget {
  const RechargeMainScreen({super.key});

  @override
  State<RechargeMainScreen> createState() => _RechargeMainScreenState();
}

class _RechargeMainScreenState extends State<RechargeMainScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedOperator = 'Grameenphone';
  int _connectionTypeIndex = 0; // 0 = Prepaid, 1 = Postpaid
  double _enteredAmount = 0;
  double _lastKnownBalance = 0;
  bool _isSubmitting = false;

  static const List<String> _operators = [
    'Grameenphone',
    'Robi',
    'Banglalink',
    'Airtel',
    'Teletalk',
  ];

  static const List<String> _connectionTypes = ['Prepaid', 'Postpaid'];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {
        _enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool _isBalanceSufficient(double rechargeBalance) =>
      rechargeBalance >= 20 && _enteredAmount >= 20 && _enteredAmount <= rechargeBalance;

  void _submit(BuildContext context, String uid, String userName) {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    context.read<RechargeBloc>().add(
          SubmitRechargeRequest(
            uid: uid,
            userName: userName,
            phone: _phoneController.text.trim(),
            operator: _selectedOperator,
            connectionType: _connectionTypes[_connectionTypeIndex],
            amount: _enteredAmount,
          ),
        );
  }

  void _openHistory(BuildContext context, String uid) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              sl<RechargeHistoryBloc>()..add(WatchRechargeHistory(uid)),
          child: const RechargeHistoryScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RechargeBloc, RechargeState>(
      listenWhen: (prev, curr) =>
          curr is RechargeSubmitted ||
          curr is RechargeError ||
          curr is RechargeValidationError,
      listener: (context, state) {
        if (state is RechargeSubmitted) {
          setState(() => _isSubmitting = false);
          _phoneController.clear();
          _amountController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else if (state is RechargeError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, rechargeState) {
        if (rechargeState is RechargeBalanceLoaded) {
          _lastKnownBalance = rechargeState.balance;
        }
        final double rechargeBalance = _lastKnownBalance;
        final bool isSubmitting =
            _isSubmitting || rechargeState is RechargeSubmitting;

        return BlocBuilder<UserBloc, UserState>(
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, userState) {
            if (userState is! UserLoaded) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            final user = userState.user;

            return Scaffold(
              backgroundColor: const Color(0xFFF0F4F8),
              body: CustomScrollView(
                slivers: [
                  // ─── Premium App Bar ────────────────────────────────────
                  SliverAppBar(
                    expandedHeight: 180,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: const Color(0xFF1E293B),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primary, // Deep dark blue/navy
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // ─── Left: Balance Display ─────────────
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.account_balance_wallet_rounded, color: Colors.amber, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                'বর্তমান ওয়ালেট ব্যালেন্স',
                                                style: GoogleFonts.manrope(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '৳ ${rechargeBalance.toStringAsFixed(2)}',
                                            style: GoogleFonts.manrope(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.amber,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // ─── Right: Commission Badge & Add Balance ─────────
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0F766E).withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: const Color(0xFF0D9488)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('✨', style: TextStyle(fontSize: 12)),
                                              const SizedBox(width: 4),
                                              Text(
                                                '২% রিচার্জ কমিশন',
                                                style: GoogleFonts.manrope(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF2DD4BF),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        GestureDetector(
                                          onTap: () =>
                                              context.push('/home/recharge/add-balance'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(30),
                                              border: Border.all(
                                                  color: Colors.white38, width: 1),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.add,
                                                    color: Colors.white, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'ব্যালেন্স যোগ',
                                                  style: GoogleFonts.manrope(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'মোবাইল রিচার্জ',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.history_rounded,
                            color: Colors.white, size: 24),
                        tooltip: 'রিচার্জ হিস্ট্রি',
                        onPressed: () => _openHistory(context, user.uid),
                      ),
                    ],
                    titleSpacing: 0,
                  ),

                  // ─── Form Body ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
                              children: [
                                _SectionCard(
                                  children: [
                                    // Phone Number
                                    _FieldLabel(label: 'মোবাইল নম্বর'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _phoneController,
                                      enabled: !isSubmitting,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(11),
                                      ],
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        letterSpacing: 1.2,
                                      ),
                                      decoration: _inputDecoration(
                                        hint: '017XXXXXXX',
                                        prefixIcon: Icons.phone_android_rounded,
                                      ),
                                      validator: (v) {
                                        final val = v?.trim() ?? '';
                                        if (val.isEmpty) return 'মোবাইল নম্বর দিন';
                                        if (val.length != 11) {
                                          return '১১ সংখ্যার নম্বর দিন';
                                        }
                                        if (!val.startsWith('0')) {
                                          return '০ দিয়ে শুরু করুন';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Operator Selection
                                    _FieldLabel(label: 'অপারেটর'),
                                    const SizedBox(height: 8),
                                    _OperatorChips(
                                      operators: _operators,
                                      selected: _selectedOperator,
                                      enabled: !isSubmitting,
                                      onChanged: (val) =>
                                          setState(() => _selectedOperator = val),
                                    ),

                                    const SizedBox(height: 20),

                                    // Connection Type
                                    _FieldLabel(label: 'সংযোগের ধরন (SIM Type)'),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: !isSubmitting
                                                ? () => setState(
                                                    () => _connectionTypeIndex = 0)
                                                : null,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 12),
                                              decoration: BoxDecoration(
                                                color: _connectionTypeIndex == 0
                                                    ? AppColors.primary
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: _connectionTypeIndex == 0
                                                      ? AppColors.primary
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.circle,
                                                      size: 10,
                                                      color: _connectionTypeIndex == 0
                                                          ? Colors.white
                                                          : Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      'প্রিপেইড (Prepaid)',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.manrope(
                                                        color: _connectionTypeIndex == 0
                                                            ? Colors.white
                                                            : AppColors.textPrimary,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: !isSubmitting
                                                ? () => setState(
                                                    () => _connectionTypeIndex = 1)
                                                : null,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 12),
                                              decoration: BoxDecoration(
                                                color: _connectionTypeIndex == 1
                                                    ? AppColors.primary
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: _connectionTypeIndex == 1
                                                      ? AppColors.primary
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.circle,
                                                      size: 10,
                                                      color: _connectionTypeIndex == 1
                                                          ? Colors.white
                                                          : Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      'পোস্টপেইড (Postpaid)',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.manrope(
                                                        color: _connectionTypeIndex == 1
                                                            ? Colors.white
                                                            : AppColors.textPrimary,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Amount
                                    _FieldLabel(label: 'রিচার্জের পরিমাণ (Amount in BDT)'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _amountController,
                                      enabled: !isSubmitting,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: false),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: GoogleFonts.manrope(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      decoration: _inputDecoration(
                                        hint: '0.00',
                                        prefixIcon: Icons.currency_exchange_rounded,
                                        prefixText: '৳ ',
                                      ),
                                      validator: (v) {
                                        final amount =
                                            double.tryParse(v?.trim() ?? '') ?? 0;
                                        if (amount < 20) return 'সর্বনিম্ন ৳২০ রিচার্জ করুন';
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 12),
                                    // Quick Amount Chips
                                    _QuickAmountChips(
                                      enabled: !isSubmitting,
                                      onAmountSelected: (amt) {
                                        _amountController.text = amt.toInt().toString();
                                        setState(() {
                                          _enteredAmount = amt;
                                        });
                                      },
                                    ),

                                    // Insufficient balance warning or min 20 TK warning
                                    if (_enteredAmount > 0 &&
                                        !_isBalanceSufficient(rechargeBalance))
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF3CD),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                                color: const Color(0xFFFFCA28)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.warning_amber_rounded,
                                                  color: Color(0xFFE65100), size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _enteredAmount < 20
                                                      ? 'সর্বনিম্ন রিচার্জ পরিমাণ ৳২০'
                                                      : rechargeBalance < 20
                                                          ? 'রিচার্জ ব্যালেন্স কমপক্ষে ৳২০ থাকতে হবে। প্রথমে ব্যালেন্স যোগ করুন।'
                                                          : 'পর্যাপ্ত রিচার্জ ব্যালেন্স নেই (৳${rechargeBalance.toStringAsFixed(2)} আছে)',
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 12,
                                                    color: const Color(0xFFE65100),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (isSubmitting)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),

                            // Submit Button
                            AnimatedOpacity(
                              opacity: _isBalanceSufficient(rechargeBalance) &&
                                      !isSubmitting
                                  ? 1.0
                                  : 0.5,
                              duration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: (_isBalanceSufficient(
                                              rechargeBalance) &&
                                          !isSubmitting)
                                      ? () => _submit(context, user.uid, user.name)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    disabledBackgroundColor:
                                        AppColors.primary.withValues(alpha: 0.5),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isSubmitting
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('⚡ ', style: TextStyle(fontSize: 18, color: Colors.amber)),
                                            Text(
                                              'রিচার্জ নিশ্চিত করুন (৳${_enteredAmount.toInt()})',
                                              style: GoogleFonts.manrope(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            // Security Note
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.security_rounded, color: Colors.green, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'নিরাপদ ও এনক্রিপ্টেড পেমেন্ট প্রসেসিং',
                                  style: GoogleFonts.manrope(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.manrope(
          color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 20),
      prefixText: prefixText,
      prefixStyle: GoogleFonts.manrope(
          color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.8),
      ),
    );
  }
}

// ─── Reusable sub-widgets ──────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _OperatorChips extends StatelessWidget {
  final List<String> operators;
  final String selected;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const _OperatorChips({
    required this.operators,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  Color _getOperatorColor(String op) {
    switch (op) {
      case 'Grameenphone':
        return Colors.blue;
      case 'Banglalink':
        return Colors.orange;
      case 'Robi':
        return Colors.red;
      case 'Airtel':
        return Colors.redAccent;
      case 'Teletalk':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: operators.map((op) {
          final isSelected = op == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getOperatorColor(op),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(op == 'Grameenphone' ? 'GP' : op),
                ],
              ),
              selected: isSelected,
              onSelected: enabled ? (v) => onChanged(op) : null,
              backgroundColor: Colors.white,
              selectedColor: Colors.white,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                ),
              ),
              labelStyle: GoogleFonts.manrope(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickAmountChips extends StatelessWidget {
  final ValueChanged<double> onAmountSelected;
  final bool enabled;

  const _QuickAmountChips({required this.onAmountSelected, this.enabled = true});

  final List<double> amounts = const [20, 50, 100, 200, 500, 1000];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: amounts.map((amt) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text('৳${amt.toInt()}'),
              onPressed: enabled ? () => onAmountSelected(amt) : null,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              labelStyle: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
