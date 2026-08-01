import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/presentation/bloc/job_submit_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/job_submit_event.dart';
import 'package:global_earn/features/home/presentation/bloc/job_submit_state.dart';

class ProofImagePicker extends StatelessWidget {
  const ProofImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobSubmitBloc, JobSubmitState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        final images = state is JobDetailLoaded ? state.proofImages : List<File?>.filled(3, null);

        return Row(
          children: [
            Expanded(
              child: _ProofSlotWidget(
                index: 0,
                title: 'প্রমাণ ১',
                imageFile: images.isNotEmpty ? images[0] : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ProofSlotWidget(
                index: 1,
                title: 'প্রমাণ ২',
                imageFile: images.length > 1 ? images[1] : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ProofSlotWidget(
                index: 2,
                title: 'প্রমাণ ৩',
                imageFile: images.length > 2 ? images[2] : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProofSlotWidget extends StatelessWidget {
  final int index;
  final String title;
  final File? imageFile;

  const _ProofSlotWidget({
    required this.index,
    required this.title,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (imageFile == null) {
          _pickImage(context, index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 100, // Compact height
        decoration: BoxDecoration(
          color: imageFile != null
              ? Colors.transparent
              : AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: imageFile != null
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.4),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(imageFile!, fit: BoxFit.cover),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          if (context.mounted) {
                            context.read<JobSubmitBloc>().add(ProofImageRemoved(index));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, int index) async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (xFile == null) return;
      if (context.mounted) {
        context.read<JobSubmitBloc>().add(ProofImagePicked(index, File(xFile.path)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ছবি নির্বাচন করতে সমস্যা হয়েছে'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
