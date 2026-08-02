import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DepositHistoryScreen extends StatelessWidget {
  const DepositHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ডিপোজিট হিস্ট্রি',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: currentUser == null
          ? Center(
              child: Text(
                'অনুগ্রহ করে লগইন করুন',
                style: GoogleFonts.hindSiliguri(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('deposit_invoices')
                  .where('uid', isEqualTo: currentUser.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'হিস্ট্রি লোড করতে সমস্যা হয়েছে',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                // Calculate summary metrics
                double totalCompleted = 0.0;
                int pendingCount = 0;

                for (final doc in docs) {
                  final data = doc.data();
                  final status = (data['status'] ?? '').toString().toLowerCase().trim();
                  final amount = num.tryParse(data['amount']?.toString() ?? '0')?.toDouble() ?? 0.0;

                  if (status == 'completed' || status == 'approved') {
                    totalCompleted += amount;
                  } else if (status == 'pending' || status == 'processing') {
                    pendingCount++;
                  }
                }

                return Column(
                  children: [
                    // Summary Cards
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'মোট ডিপোজিট',
                              value: '৳ ${totalCompleted.toStringAsFixed(totalCompleted.truncateToDouble() == totalCompleted ? 0 : 2)}',
                              icon: Icons.account_balance_wallet_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'পেন্ডিং ইনভয়েস',
                              value: '$pendingCount টি',
                              icon: Icons.hourglass_top_rounded,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List or Empty State
                    Expanded(
                      child: docs.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: docs.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                final data = doc.data();
                                return _buildDepositInvoiceCard(doc.id, data);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hindSiliguri(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositInvoiceCard(String docId, Map<String, dynamic> data) {
    final status = (data['status'] ?? 'pending').toString().toLowerCase().trim();
    final rawAmount = data['amount'];
    final amount = num.tryParse(rawAmount?.toString() ?? '0')?.toDouble() ?? 0.0;
    final formattedAmount = amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);

    // Payment method or description
    final method = (data['method'] ?? data['payment_method'] ?? data['gateway'] ?? 'অনলাইন ডিপোজিট').toString();
    final invoiceId = (data['invoice_id'] ?? data['invoiceId'] ?? data['transaction_id'] ?? data['trx_id'] ?? docId).toString();

    // Date formatting
    final createdAtRaw = data['createdAt'];
    DateTime date = DateTime.now();
    if (createdAtRaw != null) {
      if (createdAtRaw is Timestamp) {
        date = createdAtRaw.toDate();
      } else if (createdAtRaw is int) {
        date = DateTime.fromMillisecondsSinceEpoch(createdAtRaw);
      } else if (createdAtRaw is String) {
        date = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
      }
    }
    final formattedDate = DateFormat('MMM dd, yyyy, hh:mm a').format(date);

    // Status Styling
    final Color badgeBg;
    final Color badgeColor;
    final String badgeText;
    final IconData statusIcon;

    if (status == 'completed' || status == 'approved') {
      badgeBg = const Color(0xFFE8F5E9);
      badgeColor = const Color(0xFF2E7D32);
      badgeText = 'সফল';
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (status == 'failed' || status == 'cancelled' || status == 'rejected') {
      badgeBg = const Color(0xFFFFEBEE);
      badgeColor = const Color(0xFFC62828);
      badgeText = 'ব্যর্থ';
      statusIcon = Icons.cancel_outlined;
    } else {
      badgeBg = const Color(0xFFFFF3E0);
      badgeColor = const Color(0xFFE65100);
      badgeText = 'পেন্ডিং';
      statusIcon = Icons.access_time_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Invoice Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ইনভয়েস: #$invoiceId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳ $formattedAmount',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 10),

          // Bottom Row: Date & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    formattedDate,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Dynamic Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: badgeColor, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: GoogleFonts.hindSiliguri(
                        color: badgeColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'কোনো ডিপোজিট হিস্ট্রি পাওয়া যায়নি',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'আপনার ডিপোজিট সফল হলে এখানে বিস্তারিত হিস্ট্রি দেখতে পাবেন।',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
