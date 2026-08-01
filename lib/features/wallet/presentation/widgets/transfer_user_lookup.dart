import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_event.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_state.dart';

class TransferUserLookup extends StatelessWidget {
  final TextEditingController controller;
  final String currentUid;

  const TransferUserLookup({
    super.key,
    required this.controller,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'প্রাপকের ইউজার আইডি বা ফোন নম্বর দিন',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            border: Border.all(color: AppColors.outline),
          ),
          child: TextField(
            controller: controller,
            onChanged: (val) {
              if (val.isEmpty) {
                context.read<TransferBloc>().add(ClearSearch());
              } else {
                context.read<TransferBloc>().add(
                  SearchReceiver(val, currentUid),
                );
              }
            },
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'ID অথবা ফোন নম্বর',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.person_search, color: AppColors.secondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        BlocBuilder<TransferBloc, TransferState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state.status == TransferStatus.searching) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (state.status == TransferStatus.receiverNotFound) {
              return const Center(
                child: Text(
                  'ব্যবহারকারী পাওয়া যায়নি',
                  style: TextStyle(color: AppColors.error, fontSize: 14),
                ),
              );
            }
            if (state.status == TransferStatus.selfTransferError) {
              return const Center(
                child: Text(
                  'নিজের একাউন্টে ট্রান্সফার করা যাবে না',
                  style: TextStyle(color: AppColors.error, fontSize: 14),
                ),
              );
            }
            if (state.receiver != null) {
              final user = state.receiver!;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  border: Border.all(color: AppColors.secondary, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 2,
                        ),
                        color: AppColors.outline.withValues(alpha: 0.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: user.profileImageUrl != null
                            ? Image.network(
                                user.profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person,
                                      color: AppColors.textSecondary,
                                      size: 30,
                                    ),
                              )
                            : const Icon(
                                Icons.person,
                                color: AppColors.textSecondary,
                                size: 30,
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: AppColors.secondary,
                                size: 16,
                              ),
                            ],
                          ),
                          Text(
                            'ID: @${user.referCode}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Text(
                        'নিশ্চিত',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
