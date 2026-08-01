import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';

/// Large circular badge at the top of each bonus screen showing the bonus amount.
class BonusAmountCircle extends StatelessWidget {
  final String amount;
  final String? subtitle;
  final IconData? icon;

  const BonusAmountCircle({
    super.key,
    required this.amount,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.coral, Color(0xFF00B8D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 4),
            ],
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Status badge: Running / Completed / Claimed
class BonusStatusBadge extends StatelessWidget {
  final String status;

  const BonusStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'claimed' => ('✅ Claimed', const Color(0xFF0BA360)),
      'completed' => ('🎯 Completed', AppColors.coral),
      _ => ('🔄 Running', const Color(0xFFF59E0B)),
    };

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

/// Info card with a descriptive message
class BonusInfoCard extends StatelessWidget {
  final String message;

  const BonusInfoCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.coral.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.coral,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phase progress card
class BonusPhaseCard extends StatelessWidget {
  final String title;
  final int current;
  final int required;
  final String label;
  final String needMoreLabel;
  final VoidCallback? onSeeMembers;
  final String seeButtonLabel;

  const BonusPhaseCard({
    super.key,
    required this.title,
    required this.current,
    required this.required,
    required this.label,
    required this.needMoreLabel,
    this.onSeeMembers,
    this.seeButtonLabel = 'See Members',
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / required).clamp(0.0, 1.0);
    final needMore = (required - current).clamp(0, required);
    final isDone = current >= required;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? const Color(0xFF0BA360).withValues(alpha: 0.5)
              : AppColors.outline,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSubtle,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFF0BA360).withValues(alpha: 0.12)
                      : AppColors.coral.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.pending_rounded,
                  color: isDone ? const Color(0xFF0BA360) : AppColors.coral,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$current / $required',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDone ? const Color(0xFF0BA360) : AppColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? const Color(0xFF0BA360) : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label: $current',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                isDone ? '✅ সম্পন্ন' : '$needMoreLabel: $needMore',
                style: TextStyle(
                  fontSize: 12,
                  color: isDone
                      ? const Color(0xFF0BA360)
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (onSeeMembers != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onSeeMembers,
                icon: const Icon(Icons.people_outline_rounded, size: 16),
                label: Text(seeButtonLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Claim button at the bottom
class BonusClaimButton extends StatelessWidget {
  final bool canClaim;
  final bool isLoading;
  final bool alreadyClaimed;
  final String label;
  final VoidCallback? onClaim;

  const BonusClaimButton({
    super.key,
    required this.canClaim,
    required this.isLoading,
    required this.alreadyClaimed,
    required this.label,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final Color btnColor = alreadyClaimed
        ? Colors.grey.shade400
        : canClaim
        ? const Color(0xFF0BA360)
        : Colors.grey.shade400;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (canClaim && !alreadyClaimed && !isLoading) ? onClaim : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: canClaim && !alreadyClaimed ? 4 : 0,
          shadowColor: const Color(0xFF0BA360).withValues(alpha: 0.4),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                alreadyClaimed ? '✅ দাবি করা হয়েছে' : label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
