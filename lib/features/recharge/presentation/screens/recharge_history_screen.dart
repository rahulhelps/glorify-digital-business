import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_history_bloc.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_history_state.dart';

class RechargeHistoryScreen extends StatelessWidget {
  const RechargeHistoryScreen({super.key});

  static const Map<String, String> _operatorShort = {
    'Grameenphone': 'GP',
    'Robi': 'RB',
    'Banglalink': 'BL',
    'Airtel': 'AT',
    'Teletalk': 'TT',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '\u09B0\u09BF\u099A\u09BE\u09B0\u099C \u09B9\u09BF\u09B8\u09CD\u099F\u09CD\u09B0\u09BF',
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<RechargeHistoryBloc, RechargeHistoryState>(
        builder: (context, state) {
          if (state is RechargeHistoryLoading) {
            return const _RechargeHistoryShimmer();
          }
          if (state is RechargeHistoryError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.error,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }
          if (state is RechargeHistoryLoaded) {
            if (state.requests.isEmpty) {
              return Center(
                child: Text(
                  '\u0995\u09CB\u09A8\u09CB \u09B0\u09C7\u0995\u09B0\u09CD\u09A1 \u09AA\u09BE\u0993\u09DF\u09BE \u09AF\u09BE\u09DF\u09A8\u09BF',
                  style: GoogleFonts.manrope(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                return _RechargeHistoryCard(
                  data: state.requests[index],
                  operatorShort: _operatorShort,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RechargeHistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, String> operatorShort;

  const _RechargeHistoryCard({
    required this.data,
    required this.operatorShort,
  });

  @override
  Widget build(BuildContext context) {
    final operator = data['operator'] as String? ?? 'Unknown';
    final phone = data['phone'] as String? ?? '';
    final connectionType = data['connectionType'] as String? ?? 'Prepaid';
    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final status = (data['status'] as String? ?? 'pending').toLowerCase();
    final timestamp = _parseTimestamp(data);
    final badge = _statusStyle(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    operatorShort[operator] ??
                        operator.substring(0, 2).toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phone,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      connectionType,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\u09F3 ${amount.toStringAsFixed(2)}',
                    style: GoogleFonts.manrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: badge.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge.label,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badge.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.outline),
          ),
          Text(
            _formatTimestamp(timestamp),
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseTimestamp(Map<String, dynamic> data) {
    final raw = data['submittedAt'] ?? data['timestamp'];
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }

  String _formatTimestamp(DateTime? date) {
    if (date == null) return '\u2014';
    return DateFormat('dd MMMM, yyyy - hh:mm a').format(date);
  }

  _StatusStyle _statusStyle(String status) {
    switch (status) {
      case 'success':
      case 'completed':
        return const _StatusStyle(
          label: 'Success',
          background: Color(0xFFE8F5E9),
          foreground: Color(0xFF1B5E20),
        );
      case 'failed':
      case 'rejected':
        return const _StatusStyle(
          label: 'Failed',
          background: Color(0xFFFFEBEE),
          foreground: Color(0xFFB71C1C),
        );
      default:
        return const _StatusStyle(
          label: 'Pending',
          background: Color(0xFFFFF8E1),
          foreground: Color(0xFFE65100),
        );
    }
  }
}

class _StatusStyle {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });
}

class _RechargeHistoryShimmer extends StatefulWidget {
  const _RechargeHistoryShimmer();

  @override
  State<_RechargeHistoryShimmer> createState() =>
      _RechargeHistoryShimmerState();
}

class _RechargeHistoryShimmerState extends State<_RechargeHistoryShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _shimmerBox(48, 48, radius: 14),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmerBox(double.infinity, 14),
                            const SizedBox(height: 8),
                            _shimmerBox(80, 12),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _shimmerBox(72, 16),
                          const SizedBox(height: 8),
                          _shimmerBox(64, 24, radius: 20),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _shimmerBox(double.infinity, 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _shimmerBox(double width, double height, {double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + _controller.value * 2, 0),
          end: Alignment(1.0 + _controller.value * 2, 0),
          colors: const [
            Color(0xFFE8EDF3),
            Color(0xFFF5F8FC),
            Color(0xFFE8EDF3),
          ],
        ),
      ),
    );
  }
}