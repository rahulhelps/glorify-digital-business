import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/data/models/micro_job_model.dart';

class JobGrid extends StatelessWidget {
  final List<MicroJobModel> jobs;
  const JobGrid({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    // ── Apply sorting logic to push "পূর্ণ" (full) jobs to the bottom ──
    final activeJobs = jobs.where((job) => job.availableSlots > 0).toList();
    final fullJobs = jobs.where((job) => job.availableSlots <= 0).toList();
    final sortedJobs = [...activeJobs, ...fullJobs];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62, 
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _JobCard(job: sortedJobs[index]),
        childCount: sortedJobs.length,
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final MicroJobModel job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final double progress = job.totalJobLimit > 0 
        ? (job.completedCount / job.totalJobLimit).clamp(0.0, 1.0) 
        : 0.0;
    
    final bool isFull = job.completedCount >= job.totalJobLimit;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/home/job-detail/${job.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Feature image ────────────────────────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: job.featureImage != null && job.featureImage!.isNotEmpty
                      ? Image.network(
                          job.featureImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),

              // ── Card body ────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '৳${job.perJobAmount % 1 == 0 ? job.perJobAmount.toInt() : job.perJobAmount} BDT',
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        job.jobName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const Spacer(),

                      // Slots text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.people_outline, size: 12, color: AppColors.textSecondary),
                              SizedBox(width: 4),
                              Text(
                                'অবশিষ্ট স্লট:',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                              ),
                            ],
                          ),
                          Text(
                            '${job.completedCount} / ${job.totalJobLimit} জন',
                            style: const TextStyle(
                              color: Color(0xFFFF9800),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Action Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isFull ? 'সম্পূর্ণ ➔' : 'কাজ করুন ➔',
                              style: TextStyle(
                                color: isFull ? AppColors.textSecondary : const Color(0xFF0288D1),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.black12,
          size: 40,
        ),
      ),
    );
  }
}
