import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_event.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_state.dart';

class ImagePickerSection extends StatelessWidget {
  const ImagePickerSection({super.key});

  Future<void> _pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return; // User cancelled

      if (context.mounted) {
        context.read<PostJobBloc>().add(PostJobImagePicked(File(image.path)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('??? ???????? ???? ?????? ?????'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostJobBloc, PostJobState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To assign micro jobs to users, please fill out the following steps.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _pickImage(context),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: state.image != null
                        ? AppColors.secondary
                        : AppColors.primary.withValues(alpha: 0.5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  image: state.image != null
                      ? DecorationImage(
                          image: FileImage(state.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: state.image != null
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Select 1 Feature Image*',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

