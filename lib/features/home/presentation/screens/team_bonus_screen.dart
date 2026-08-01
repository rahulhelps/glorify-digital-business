import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/presentation/bloc/bonus_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/bonus_event.dart';
import 'package:global_earn/features/home/presentation/bloc/bonus_state.dart';
import 'package:global_earn/features/home/presentation/widgets/bonus/bonus_shared_widgets.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/shared/widgets/verification_guard.dart';

const _kBonusType = 'leadership_bonus';
const _kBonusAmount = 100.0;
const _kL1Required = 15;

class TeamBonusScreen extends StatefulWidget {
  const TeamBonusScreen({super.key});

  @override
  State<TeamBonusScreen> createState() => _TeamBonusScreenState();
}

class _TeamBonusScreenState extends State<TeamBonusScreen> {
  Map<String, dynamic>? _cachedBonusData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BonusBloc>().add(const LoadBonusStatus(_kBonusType));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return VerificationGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Leadership Bonus',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            tooltip: 'Bonus History',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('শীঘ্রই আসছে'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: BlocConsumer<BonusBloc, BonusState>(
        listener: (context, state) {
          if (state is BonusClaimed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('🎉 Leadership Bonus সফলভাবে নেওয়া হয়েছে!'),
                backgroundColor: const Color(0xFF0BA360),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
          if (state is BonusError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, bonusState) {
          if (bonusState is BonusLoaded) {
            _cachedBonusData = bonusState.data;
          }

          final hasCachedData = _cachedBonusData != null;
          if (!hasCachedData &&
              (bonusState is BonusInitial || bonusState is BonusLoading)) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (bonusState is BonusError && !hasCachedData) {
            return _TeamErrorBody(message: bonusState.message);
          }

          return BlocBuilder<UserBloc, UserState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, userState) {
              // Use verified counts from BonusLoaded.data (direct Firestore query)
              // Do NOT use user.team.level1Business — it may be stale for existing users
              int l1 = 0;
              int claimedCount = 0;
              final isClaiming = bonusState is BonusLoading && hasCachedData;

              final bonusData = bonusState is BonusLoaded
                  ? bonusState.data
                  : _cachedBonusData;
              if (bonusData != null) {
                l1 = (bonusData['level1Verified'] as int?) ?? 0;
                claimedCount = (bonusData['claimedCount'] as int?) ?? 0;
              }

              final int requiredMembers = (claimedCount + 1) * 15;
              final bool phase1Done = l1 >= requiredMembers;
              final bool canClaim = phase1Done;
              final bool alreadyClaimed = false;

              final badgeStatus = canClaim
                  ? 'completed'
                  : 'running';

              int currentProgress = l1 - (claimedCount * 15);
              if (currentProgress < 0) currentProgress = 0;

              final referCode = userState is UserLoaded
                  ? userState.user.referCode
                  : '';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. Premium Top Header (Dark & Gold)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A1C16), Color(0xFF1A110E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB8860B).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFB8860B).withValues(alpha: 0.5)),
                                ),
                                child: const Text(
                                  '👑 LEADERSHIP REWARD',
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'লিডারশিপ বোনাস (Leadership Bonus)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB8860B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFB8860B).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'লিডারশিপ রিওয়ার্ড বোনাস',
                                        style: TextStyle(color: Color(0xFFFFD700), fontSize: 12),
                                      ),
                                      Text(
                                        '৳১০০ টাকা নিশ্চিত',
                                        style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. Instructions Card (Soft Orange)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFD1A3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE0B2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('🔥', style: TextStyle(fontSize: 18)),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'লিডারশিপ বোনাস নির্দেশনা',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFCC5500),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE0B2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFFB74D)),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.loop_rounded, size: 12, color: Color(0xFFE65100)),
                                    SizedBox(width: 4),
                                    Text(
                                      'আনলিমিটেড ক্লেইম',
                                      style: TextStyle(color: Color(0xFFE65100), fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(text: 'একসাথে '),
                                TextSpan(
                                  text: '১৫টি ভেরিফাইড রেফার',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100), decoration: TextDecoration.underline),
                                ),
                                TextSpan(text: ' সম্পন্ন করুন এবং জিতে নিন '),
                                TextSpan(
                                  text: '১০০ টাকা মেগা বোনাস!',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00897B), decoration: TextDecoration.underline),
                                ),
                                TextSpan(text: ' যতবার ১৫টি ভেরিফাইড রেফার সম্পন্ন হবে, ততবারই ১০০ টাকা করে ক্লেইম করতে পারবেন।'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Analytics Grid (2x2)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: [
                        _buildGridCard('মোট ভেরিফাইড রেফার', l1.toString(), const Color(0xFF1E3A8A)),
                        _buildGridCard('টার্গেট রেফার', '15', const Color(0xFFEA580C)),
                        _buildGridCard('বাকি আছে', '${(15 - currentProgress) > 0 ? (15 - currentProgress) : 0}', const Color(0xFF4338CA)),
                        _buildGridCard('বোনাস অ্যামাউন্ট', '৳100', const Color(0xFF059669)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 5. Target Tracker & Actions
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFE0B2), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFE0B2).withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.star_rounded, color: Color(0xFFFF9800), size: 24),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '১৫-রেফার মেগা টার্গেট ট্র্যাকার',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '১৫টি অব্যবহৃত ভেরিফাইড রেফার একত্র হলেই ১০০ টাকা মেগা বোনাস ক্লেইম বাটন আনলক হবে।',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFFCC80)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFFE65100)),
                                const SizedBox(width: 6),
                                Text(
                                  'চলতি টার্গেট: $currentProgress / 15',
                                  style: const TextStyle(
                                    color: Color(0xFFE65100),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // See Level 1 Members Button
                          // SizedBox(
                          //   width: double.infinity,
                          //   child: OutlinedButton.icon(
                          //     onPressed: referCode.isNotEmpty
                          //         ? () => context.push(
                          //             '/network/downline-report',
                          //             extra: referCode,
                          //           )
                          //         : null,
                          //     icon: const Icon(Icons.group_outlined, size: 18),
                          //     label: const Text('See Level 1 Members', style: TextStyle(fontWeight: FontWeight.bold)),
                          //     style: OutlinedButton.styleFrom(
                          //       foregroundColor: AppColors.primary,
                          //       side: const BorderSide(color: AppColors.primary),
                          //       padding: const EdgeInsets.symmetric(vertical: 12),
                          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 12),
                          
                          // Claim Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: (canClaim && !isClaiming)
                                  ? () {
                                      context.read<BonusBloc>().add(
                                        const ClaimBonus(
                                          bonusType: _kBonusType,
                                          amount: _kBonusAmount,
                                          bonusName: 'Leadership',
                                        ),
                                      );
                                    }
                                  : null,
                              icon: isClaiming
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.card_giftcard_rounded, size: 18),
                              label: const Text(
                                'Claim Leadership Bonus',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: canClaim ? const Color(0xFFFFB300) : Colors.grey.shade400,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: canClaim ? 2 : 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    ));
  }

  Widget _buildGridCard(String title, String value, Color valueColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: valueColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamErrorBody extends StatelessWidget {
  final String message;
  const _TeamErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<BonusBloc>().add(
                const LoadBonusStatus(_kBonusType),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'আবার চেষ্টা করুন',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


