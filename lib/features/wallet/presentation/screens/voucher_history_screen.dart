import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/wallet/presentation/widgets/voucher_history/purchased_voucher_card.dart';
import 'package:global_earn/features/wallet/presentation/widgets/voucher_history/redeem_history_card.dart';
import 'package:global_earn/features/wallet/domain/repositories/voucher_repository.dart';
import 'package:global_earn/service_locator.dart';

class VoucherHistoryScreen extends StatelessWidget {
  const VoucherHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
            'ভাউচার হিস্ট্রি',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'আমার ভাউচার'),
              Tab(text: 'রিডিম হিস্ট্রি'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        body: BlocBuilder<UserBloc, UserState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, userState) {
            if (userState is! UserLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final uid = userState.user.uid;

            return TabBarView(
              children: [
                _PurchasedVouchersTab(uid: uid),
                _RedeemHistoryTab(uid: uid),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PurchasedVouchersTab extends StatelessWidget {
  final String uid;
  const _PurchasedVouchersTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sl<VoucherRepository>().getMyPurchasedVouchers(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final vouchers = snapshot.data ?? [];

        if (vouchers.isEmpty) {
          return const Center(
            child: Text(
              'কোনো ভাউচার কেনা হয়নি',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vouchers.length,
          itemBuilder: (context, index) {
            return PurchasedVoucherCard(voucher: vouchers[index]);
          },
        );
      },
    );
  }
}

class _RedeemHistoryTab extends StatelessWidget {
  final String uid;
  const _RedeemHistoryTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sl<VoucherRepository>().getVoucherHistory(
        uid: uid,
        type: 'redeem',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = snapshot.data ?? [];

        if (history.isEmpty) {
          return const Center(
            child: Text(
              'কোনো রিডিম হিস্ট্রি নেই',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            return RedeemHistoryCard(history: history[index]);
          },
        );
      },
    );
  }
}
