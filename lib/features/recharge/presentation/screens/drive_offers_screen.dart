import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_bloc.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_state.dart';
import 'package:global_earn/features/recharge/presentation/widgets/drive_offer_card.dart';
import 'package:global_earn/features/recharge/presentation/widgets/purchase_confirmation_dialog.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/shared/widgets/verification_guard.dart';

class DriveOffersScreen extends StatefulWidget {
  const DriveOffersScreen({super.key});

  @override
  State<DriveOffersScreen> createState() => _DriveOffersScreenState();
}

class _DriveOffersScreenState extends State<DriveOffersScreen> {
  String _selectedOperator = 'All Operators';
  
  final List<String> _operators = [
    'All Operators',
    'Grameenphone',
    'Robi',
    'Airtel',
    'Banglalink',
    'Teletalk'
  ];

  void _handleBuy(BuildContext context, Map<String, dynamic> offer, String uid) {
    final double offerPrice = (offer['offerPrice'] ?? 0).toDouble();

    double currentBalance = 0.0;
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      currentBalance = userState.user.withdrawableBalance;
    }

    if (currentBalance < offerPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('অপর্যাপ্ত ব্যালেন্স। আপনার ব্যালেন্স: ৳${currentBalance.toStringAsFixed(2)}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PurchaseConfirmationDialog(
        uid: uid,
        packageDetails: offer['packageDetails'] ?? '',
        operator: offer['operator'] ?? '',
        offerPrice: offerPrice,
        regularPrice: (offer['regularPrice'] ?? 0).toDouble(),
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('আপনার রিকোয়েস্ট সফলভাবে জমা হয়েছে'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VerificationGuard(
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is! UserLoaded) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final user = userState.user;
          
          return BlocBuilder<RechargeBloc, RechargeState>(
            builder: (context, rechargeState) {
              double currentBalance = 0.0;
              if (rechargeState is RechargeBalanceLoaded) {
                currentBalance = rechargeState.balance;
              }

              return Scaffold(
                backgroundColor: const Color(0xFFF0F4F8),
                body: CustomScrollView(
                  slivers: [
                    // ─── Premium App Bar ────────────────────────────────────
                    SliverAppBar(
                      expandedHeight: 160,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: AppColors.primaryDark,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => context.pop(),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.receipt_long_rounded, color: Colors.amber),
                          onPressed: () => context.push('/home/drive-offers/history'),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient( begin: AlignmentGeometry.topLeft, end: AlignmentGeometry.bottomLeft,colors: [AppColors.primary,AppColors.primaryDark]),
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
                                            BlocBuilder<UserBloc, UserState>(
                                              builder: (context, state) {
                                                double balance = 0.0;
                                                if (state is UserLoaded) {
                                                  balance = state.user.withdrawableBalance;
                                                }
                                                return Text(
                                                  '৳ ${balance.toStringAsFixed(2)}',
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.amber,
                                                    letterSpacing: -0.5,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ─── Operator Filters ────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 0, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.card_giftcard, color: Colors.amber, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'আকর্ষণীয় ড্রাইভ অফারসমূহ',
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'আপনার পছন্দের ড্রাইভ অফারটি নির্বাচন করে এখনই চালু করুন',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 40,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _operators.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final op = _operators[index];
                                  final isSelected = _selectedOperator == op;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedOperator = op),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFE0F2FE) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        op,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── Offers List ─────────────────────────────────────────
                    StreamBuilder<QuerySnapshot>(
                      stream: _selectedOperator == 'All Operators'
                          ? FirebaseFirestore.instance.collection('drive_offers').snapshots()
                          : FirebaseFirestore.instance.collection('drive_offers').where('operator', isEqualTo: _selectedOperator).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: Text('অফার লোড করতে সমস্যা হয়েছে')),
                          );
                        }
                        
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text('কোনো অফার পাওয়া যায়নি', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final data = docs[index].data() as Map<String, dynamic>;
                                return DriveOfferCard(
                                  offer: data,
                                  onBuy: () => _handleBuy(context, data, user.uid),
                                );
                              },
                              childCount: docs.length,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
