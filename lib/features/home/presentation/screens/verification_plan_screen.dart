// ignore_for_file: unnecessary_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_payment/quick_payment.dart'; // ignore: unused_import

import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/home/presentation/bloc/subscription_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/subscription_event.dart';
import 'package:global_earn/features/home/presentation/bloc/subscription_state.dart';
import 'package:global_earn/features/home/presentation/screens/payment_webview_screen.dart';
import 'package:global_earn/service_locator.dart';

class VerificationPlanScreen extends StatelessWidget {
  final UserModel user;

  const VerificationPlanScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SubscriptionBloc>(),
      child: _VerificationPlanScreenContent(user: user),
    );
  }
}

class _VerificationPlanScreenContent extends StatefulWidget {
  final UserModel user;

  // ignore: unused_element_parameter
  const _VerificationPlanScreenContent({super.key, required this.user});

  @override
  State<_VerificationPlanScreenContent> createState() => _VerificationPlanScreenContentState();
}

class _VerificationPlanScreenContentState extends State<_VerificationPlanScreenContent> {
  final Color primaryBlue = const Color(0xFF0F3D88);
  final Color lightBlue = const Color(0xFF1565C0);
  final Color background = const Color(0xFFF5F7FA);

  void _onAutoPayment() {
    context.read<SubscriptionBloc>().add(
      AutoPaymentRequested(uid: widget.user.uid, plan: 'plan320'),
    );
  }

  String _toBn(dynamic val) {
    String str = val?.toString() ?? '0';
    return str
        .replaceAll('0', '০')
        .replaceAll('1', '১')
        .replaceAll('2', '২')
        .replaceAll('3', '৩')
        .replaceAll('4', '৪')
        .replaceAll('5', '৫')
        .replaceAll('6', '৬')
        .replaceAll('7', '৭')
        .replaceAll('8', '৮')
        .replaceAll('9', '৯');
  }

  List<String> _buildReferralList(Map<String, dynamic> referral) {
    final gen1 = _toBn(referral['gen1']);
    final gen2 = _toBn(referral['gen2']);
    final gen3 = _toBn(referral['gen3']);
    final gen4 = _toBn(referral['gen4']);
    final gen5 = _toBn(referral['gen5']);
    final gen6 = _toBn(referral['gen6']);
    final gen7 = _toBn(referral['gen7']);
    final gen8 = _toBn(referral['gen8']);
    final gen9 = _toBn(referral['gen9']);
    final gen10 = _toBn(referral['gen10']);

    return [
      '১ম জেনারেশন: ৳$gen1',
      '২য় জেনারেশন: ৳$gen2 | ৩য় জেনারেশন: ৳$gen3 | ৪র্থ জেনারেশন: ৳$gen4 | ৫ম জেনারেশন: ৳$gen5',
      '৬ষ্ঠ জেনারেশন: ৳$gen6 | ৭ম জেনারেশন: ৳$gen7 | ৮ম জেনারেশন: ৳$gen8 | ৯ম জেনারেশন: ৳$gen9 | ১০ম জেনারেশন: ৳$gen10',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listenWhen: (previous, current) =>
          current is AutoPaymentLoading ||
          current is AutoPaymentUrlReady ||
          current is AutoPaymentError,
      listener: (context, state) {
        if (state is AutoPaymentUrlReady) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<SubscriptionBloc>(),
                child: PaymentWebViewScreen(
                  paymentUrl: state.paymentUrl,
                  invoiceCollectionPath: 'payment_invoices',
                ),
              ),
            ),
          );
        } else if (state is AutoPaymentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('app_config').doc('subscription').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return Scaffold(
                backgroundColor: background,
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Fallback default structure if no data
            Map<String, dynamic> configData = {};
            if (snapshot.hasData && snapshot.data!.data() != null) {
              configData = snapshot.data!.data() as Map<String, dynamic>;
            }

            final plan320Data = configData['plan320'] as Map<String, dynamic>? ?? {};
            final premiumPriceRaw = plan320Data['price']?.toString() ?? '320';
            final premiumPriceBn = _toBn(premiumPriceRaw);

            final premiumReferral = plan320Data['referral'] as Map<String, dynamic>? ?? {
              'gen1': 100, 'gen2': 45, 'gen3': 25, 'gen4': 15, 'gen5': 10,
              'gen6': 5, 'gen7': 4, 'gen8': 3, 'gen9': 2, 'gen10': 2
            };

            return Stack(
              children: [
                Scaffold(
                  backgroundColor: background,
                  appBar: AppBar(
                    title: const Text(
                      'একাউন্ট ভেরিফিকেশন',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    centerTitle: true,
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  body: Column(
                    children: [
                      // Extended Blue Header
                      Container(
                        color: primaryBlue,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: background,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: Container(
                          color: background,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            child: _buildPlanContent(premiumPriceBn, premiumReferral),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Loading overlay shown while waiting for ZiniPay payment URL
                if (state is AutoPaymentLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'পেমেন্ট শুরু হচ্ছে...',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildPlanContent(String premiumPriceBn, Map<String, dynamic> referral) {


    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF4F9FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ভেরিফিকেশন ফি',
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryBlue,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '৳$premiumPriceBn',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: primaryBlue,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'সকল সুবিধা আনলক',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'VERIFIED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFD6E4F0)),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryBlue.withValues(alpha: 0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_open_rounded, color: primaryBlue, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'সকল প্রজেক্ট আনলক হবে',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'একাউন্ট ভেরিফাই করলে অ্যাপের সকল প্রজেক্ট, বোনাস এবং '
                        'রিওয়ার্ডস সম্পূর্ণভাবে আনলক হয়ে যাবে — কোনো বাড়তি '
                        'শর্ত ছাড়াই।',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFD6E4F0)),
          ),

          _buildSectionTitle('জেনারেশন রেফারেল কমিশন'),
          const SizedBox(height: 16),
          _buildPremiumCommissionList(_buildReferralList(referral)),

          const SizedBox(height: 32),

          _buildActionButton(
            text: 'স্বয়ংক্রিয়ভাবে পেমেন্ট করুন (৳$premiumPriceBn)',
            onPressed: _onAutoPayment,
            isPremium: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: primaryBlue,
        letterSpacing: 0.3,
      ),
    );
  }


  Widget _buildPremiumCommissionList(List<String> items) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: primaryBlue, size: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton({required String text, required VoidCallback onPressed, required bool isPremium}) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [const Color(0xFF0A2A60), primaryBlue]
              : [primaryBlue, lightBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPremium) ...[
              const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
