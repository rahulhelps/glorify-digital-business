import 'package:flutter/material.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/data/models/micro_job_model.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailCard extends StatelessWidget {
  final MicroJobModel job;
  const JobDetailCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final isFull = job.availableSlots <= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSubtle,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Feature image ─────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
              bottom: Radius.circular(16),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: _buildImage(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row with reward badge ───────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        job.jobName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _RewardBadge(amount: job.perJobAmount),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Poster name ───────────────────────────────────────────
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.posterName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Slots remaining ───────────────────────────────────────
                Row(
                  children: [
                    Icon(
                      isFull ? Icons.block : Icons.people_alt_outlined,
                      size: 14,
                      color: isFull ? AppColors.error : AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isFull
                          ? 'সব স্লট পূর্ণ হয়ে গেছে'
                          : '${job.availableSlots} টি স্লট বাকি আছে',
                      style: TextStyle(
                        color: isFull ? AppColors.error : AppColors.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Description ───────────────────────────────────────────
                const Text(
                  'বিবরণ',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  job.jobDescription,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Job link ──────────────────────────────────────────────
                if (job.jobLink.isNotEmpty) _JobLinkButton(url: job.jobLink),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final url = job.featureImage;
    if (url != null && url.isNotEmpty) {
      return Image.network(
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
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    color: AppColors.surfaceDim,
    child: const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textSecondary,
        size: 48,
      ),
    ),
  );
}

// ── Reward badge ──────────────────────────────────────────────────────────────
class _RewardBadge extends StatelessWidget {
  final double amount;
  const _RewardBadge({required this.amount});

  @override
  Widget build(BuildContext context) {
    final label = '৳${amount % 1 == 0 ? amount.toInt() : amount}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ── Job link button ───────────────────────────────────────────────────────────
class _JobLinkButton extends StatelessWidget {
  final String url;
  const _JobLinkButton({required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        try {
          final uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('লিংক খোলা যাচ্ছে না')),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link, size: 16, color: AppColors.secondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                url,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
