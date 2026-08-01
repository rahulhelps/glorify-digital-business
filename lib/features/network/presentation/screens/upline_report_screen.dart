import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/network/domain/repositories/network_repository.dart';
import 'package:global_earn/features/network/presentation/bloc/upline_report_bloc.dart';
import 'package:global_earn/features/network/presentation/bloc/upline_report_event.dart';
import 'package:global_earn/features/network/presentation/bloc/upline_report_state.dart';
import 'package:global_earn/service_locator.dart';

class UplineReportScreen extends StatelessWidget {
  final String referredBy;

  const UplineReportScreen({super.key, required this.referredBy});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UplineReportBloc(networkRepository: sl<NetworkRepository>())
            ..add(LoadUplineReport(referredBy)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            'আপলাইন রিপোর্ট',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
        ),
        body: BlocBuilder<UplineReportBloc, UplineReportState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state is UplineReportLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is UplineReportError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }
            if (state is UplineReportLoaded) {
              if (state.uplines.isEmpty) {
                return const Center(
                  child: Text(
                    'কোনো আপলাইন পাওয়া যায়নি।',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return _buildUplineTimeline(state.uplines);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildUplineTimeline(List<UserModel> uplines) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      itemCount: uplines.length,
      itemBuilder: (context, index) {
        final upline = uplines[index];
        final isLast = index == uplines.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline Line
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSizes.spacingMd),
              // Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spacingLg),
                  child: _UplineCard(upline: upline, level: index + 1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UplineCard extends StatelessWidget {
  final UserModel upline;
  final int level;

  const _UplineCard({required this.upline, required this.level});

  @override
  Widget build(BuildContext context) {
    final joinDate = DateFormat('dd MMM yyyy').format(upline.joinedAt);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.outline),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Level Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                  ),
                  child: Text(
                    '${_getBengaliNumber(level)} আপলাইন',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                // Account Type Badge
                _buildAccountTypeBadge(upline),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMd),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: upline.profileImageUrl != null
                      ? NetworkImage(upline.profileImageUrl!)
                      : null,
                  child: upline.profileImageUrl == null
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: AppSizes.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        upline.name,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Refer code: ${upline.referCode}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSizes.spacingLg),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Join date: $joinDate',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeBadge(UserModel upline) {
    if (upline.isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0BA360).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: const Text(
          '✅ ভেরিফাইড',
          style: TextStyle(
            color: Color(0xFF0BA360),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (upline.isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: const Text(
          '⏳ পর্যালোচনাধীন',
          style: TextStyle(
            color: Color(0xFFE65100),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Text(
          'সাধারণ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  String _getBengaliNumber(int number) {
    const bengaliNumbers = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final n = number.toString();
    String result = '';
    for (int i = 0; i < n.length; i++) {
      result += bengaliNumbers[int.parse(n[i])];
    }
    // Specific Bengali ordinal mapping if needed
    final ordinals = {
      1: '১ম',
      2: '২য়',
      3: '৩য়',
      4: '৪র্থ',
      5: '৫ম',
      6: '৬ষ্ঠ',
      7: '৭ম',
      8: '৮ম',
      9: '৯ম',
      10: '১০ম',
    };
    return ordinals[number] ?? result;
  }
}

