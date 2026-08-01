import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/presentation/bloc/job_submit_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/job_submit_event.dart';
import 'package:global_earn/features/home/presentation/bloc/job_submit_state.dart';
import 'package:global_earn/features/home/presentation/widgets/job_detail/job_detail_card.dart';
import 'package:global_earn/features/home/presentation/widgets/job_detail/proof_image_picker.dart';
import 'package:global_earn/features/home/presentation/widgets/job_detail/submit_button.dart';
import 'package:global_earn/service_locator.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _proofTextCtrl = TextEditingController();

  @override
  void dispose() {
    _proofTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobSubmitBloc>()..add(LoadJobDetail(widget.jobId)),
      child: BlocListener<JobSubmitBloc, JobSubmitState>(
        listener: _onStateChange,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            title: const Text(
              'জব বিবরণ',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => context.pop(),
            ),
          ),
          body: BlocBuilder<JobSubmitBloc, JobSubmitState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              if (state is JobSubmitLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is JobSubmitError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () => context.read<JobSubmitBloc>().add(
                    LoadJobDetail(widget.jobId),
                  ),
                );
              }
              if (state is JobAlreadySubmitted) {
                return const _GuardView(
                  icon: Icons.check_circle_outline,
                  message: 'আপনি ইতোমধ্যে এই জবটি সাবমিট করেছেন',
                );
              }
              if (state is JobSlotsFull) {
                return const _GuardView(
                  icon: Icons.block,
                  message: 'এই জবের সব স্লট পূর্ণ হয়ে গেছে',
                  isError: true,
                );
              }
              if (state is JobDetailLoaded) {
                return _DetailBody(state: state, proofTextCtrl: _proofTextCtrl);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _onStateChange(BuildContext context, JobSubmitState state) {
    if (state is JobSubmitSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সাবমিশন সফল হয়েছে! অনুমোদনের জন্য অপেক্ষা করুন'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
      context.pop();
    }
    if (state is JobSubmitError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
      // Reload detail so the user can retry
      context.read<JobSubmitBloc>().add(LoadJobDetail(widget.jobId));
    }
  }
}

// ── Detail body ───────────────────────────────────────────────────────────────
class _DetailBody extends StatelessWidget {
  final JobDetailLoaded state;
  final TextEditingController proofTextCtrl;
  const _DetailBody({required this.state, required this.proofTextCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JobDetailCard(job: state.job),
          const SizedBox(height: 24),
          _SectionLabel(label: 'প্রমাণ জমা দিন'),
          const SizedBox(height: 14),
          const ProofImagePicker(),
          const SizedBox(height: 16),
          TextField(
            controller: proofTextCtrl,
            maxLines: 4,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'প্রমাণের বিবরণ লিখুন (ঐচ্ছিক)',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          SubmitButton(proofTextController: proofTextCtrl),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guard view (slots full / already submitted) ───────────────────────────────
class _GuardView extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isError;
  const _GuardView({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.secondary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('ফিরে যান'),
            ),
          ],
        ),
      ),
    );
  }
}
