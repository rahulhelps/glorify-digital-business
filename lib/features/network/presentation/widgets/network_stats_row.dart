import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';

class NetworkStatsRow extends StatelessWidget {
  final num total;
  final num unverified;
  final num verified;
  final bool isLoading;

  const NetworkStatsRow({
    super.key,
    required this.total,
    required this.unverified,
    required this.verified,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final unverifiedPercentage = total > 0 && !isLoading
        ? (unverified / total * 100).toStringAsFixed(0)
        : '0';
    final verifiedPercentage = total > 0 && !isLoading
        ? (verified / total * 100).toStringAsFixed(0)
        : '0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.group_outlined,
              value: total.toString(),
              label: 'Total',
              iconColor: AppColors.primary,
              isLoading: isLoading,
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatCardWithPill(
              icon: Icons.person_outline,
              value: unverified.toString(),
              label: 'Unverified',
              pillValue: '$unverifiedPercentage%',
              pillColor: Colors.orange,
              isLoading: isLoading,
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatCardWithPill(
              icon: Icons.verified_user_outlined,
              value: verified.toString(),
              label: 'Verified',
              pillValue: '$verifiedPercentage%',
              pillColor: Colors.green,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.grey.shade200,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final bool isLoading;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = AppColors.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _StatCardWithPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String pillValue;
  final Color pillColor;
  final bool isLoading;

  const _StatCardWithPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.pillValue,
    this.pillColor = Colors.orange,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: pillColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: pillColor, size: 18),
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: pillColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: isLoading
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: pillColor,
                  ),
                )
              : Text(
                  pillValue,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: pillColor,
                  ),
                ),
        ),
      ],
    );
  }
}
