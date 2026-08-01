import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/data/models/submission_model.dart';
import 'package:global_earn/features/home/presentation/bloc/job_approval_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/job_approval_event.dart';
import 'package:global_earn/features/home/presentation/bloc/job_approval_state.dart';

class SubmissionCard extends StatelessWidget {
  final SubmissionModel submission;

  const SubmissionCard({super.key, required this.submission});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSubtle,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.secondaryContainer,
                  child: Icon(
                    Icons.person,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.submitterName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'dd MMM yyyy, hh:mm a',
                        ).format(submission.submittedAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: submission.status),
              ],
            ),
          ),

          // ── Proof image ────────────────────────────────────────────────────
          if (submission.proofImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 90,
                child: Row(
                  children: List.generate(3, (index) {
                    if (index < submission.proofImages.length) {
                      final url = submission.proofImages[index];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _openFullScreen(context, url),
                          child: Container(
                            margin: EdgeInsets.only(right: index < 2 ? 8.0 : 0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, prog) => prog == null
                                    ? child
                                    : Container(
                                        color: AppColors.surfaceDim,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                errorBuilder: (_, x, err) => Container(
                                  color: AppColors.surfaceDim,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: AppColors.textSecondary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < 2 ? 8.0 : 0.0),
                        ),
                      );
                    }
                  }),
                ),
              ),
            ),
          ],

          // ── Proof text ─────────────────────────────────────────────────────
          if (submission.proofText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                submission.proofText,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],

          // ── Reward row ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on_outlined,
                  size: 14,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'পুরস্কার: ৳${submission.reward % 1 == 0 ? submission.reward.toInt() : submission.reward}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ── Action buttons (pending only) ───────────────────────────────────
          if (submission.status == 'pending') ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: BlocBuilder<JobApprovalBloc, JobApprovalState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  final isBusy = state is JobApprovalLoading;
                  return Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'অনুমোদন',
                          icon: Icons.check_circle_outline,
                          color: AppColors.success,
                          loading: isBusy,
                          onPressed: isBusy
                              ? null
                              : () => context.read<JobApprovalBloc>().add(
                                  ApproveSubmission(submission),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          label: 'প্রত্যাখ্যান',
                          icon: Icons.cancel_outlined,
                          color: AppColors.error,
                          loading: isBusy,
                          onPressed: isBusy
                              ? null
                              : () => context.read<JobApprovalBloc>().add(
                                  RejectSubmission(submission),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ] else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  void _openFullScreen(BuildContext context, String url) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => _FullScreenImage(url: url)));
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'approved' => ('অনুমোদিত', AppColors.success),
      'rejected' => ('প্রত্যাখ্যাত', AppColors.error),
      _ => ('অপেক্ষমাণ', const Color(0xFFF57C00)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: color.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        elevation: 0,
      ),
      onPressed: onPressed,
      icon: loading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

// ── Full-screen proof image viewer ────────────────────────────────────────────
class _FullScreenImage extends StatelessWidget {
  final String url;
  const _FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Center(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, prog) => prog == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                errorBuilder: (_, x, err) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 48,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
