import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_constants.dart';

class DailyBonusLiveTracker extends StatelessWidget {
  final String referCode;

  const DailyBonusLiveTracker({super.key, required this.referCode});

  @override
  Widget build(BuildContext context) {
    if (referCode.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate daily calendar boundaries dynamically using Bangladeshi Time (UTC+6)
    final nowBst = DateTime.now().toUtc().add(const Duration(hours: 6));
    final startOfTodayBst = DateTime(nowBst.year, nowBst.month, nowBst.day)
        .subtract(const Duration(hours: 6));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'আজকের লাইভ ভেরিফাইড রেফার হিস্ট্রি',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('referredBy', isEqualTo: referCode)
              .where('subscriptionStatus', whereIn: SubscriptionStatus.strictPremium320Statuses)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'ডেটা লোড করতে সমস্যা হয়েছে',
                  style: TextStyle(color: AppColors.error),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            final todayUsers = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final joinedAt = (data['joinedAt'] as Timestamp?)?.toDate();
              return joinedAt != null && joinedAt.isAfter(startOfTodayBst);
            }).toList();

            // Sort descending by time
            todayUsers.sort((a, b) {
              final aTime = (a.data() as Map<String, dynamic>)['joinedAt'] as Timestamp?;
              final bTime = (b.data() as Map<String, dynamic>)['joinedAt'] as Timestamp?;
              if (aTime == null || bTime == null) return 0;
              return bTime.toDate().compareTo(aTime.toDate());
            });

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowSubtle,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'আজকের ভেরিফাইড',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${todayUsers.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (todayUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'আজকে এখনো কোনো ভেরিফাইড রেফার নেই',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayUsers.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final userData = todayUsers[index].data() as Map<String, dynamic>;
                        final name = userData['name'] as String? ?? 'Unknown';
                        final phone = userData['phone'] as String? ?? '';
                        final joinedAt = (userData['joinedAt'] as Timestamp?)?.toDate();
                        
                        String displayPhone = phone;
                        if (phone.length > 4) {
                          displayPhone = '${phone.substring(0, phone.length - 4)}****';
                        }

                        String timeStr = '';
                        if (joinedAt != null) {
                          // Convert to BST
                          final localTime = joinedAt.toUtc().add(const Duration(hours: 6));
                          timeStr = DateFormat('hh:mm a').format(localTime);
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.person, color: AppColors.primary),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            displayPhone,
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0BA360).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 12, color: Color(0xFF0BA360)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0BA360),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
