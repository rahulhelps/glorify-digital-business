import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/wallet/presentation/bloc/voucher_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/voucher_event.dart';
import 'package:global_earn/features/wallet/presentation/bloc/voucher_state.dart';
import 'package:global_earn/features/wallet/presentation/widgets/voucher_history_item.dart';

class RecentVouchersList extends StatelessWidget {
  const RecentVouchersList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, userState) {
        if (userState is UserLoaded) {
          context.read<VoucherBloc>().add(
            LoadVoucherHistory(uid: userState.user.uid, limit: 10),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'সাম্প্রতিক ভাউচারসমূহ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/wallet/voucher-history'),
                  child: const Text(
                    'সব দেখুন',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlocBuilder<VoucherBloc, VoucherState>(
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                if (state is VoucherLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is VoucherLoaded) {
                  if (state.history.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'কোনো ভাউচার হিস্ট্রি নেই',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.history.length,
                    itemBuilder: (context, index) {
                      return VoucherHistoryItem(history: state.history[index]);
                    },
                  );
                }

                if (state is VoucherError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ],
        );
      },
    );
  }
}
