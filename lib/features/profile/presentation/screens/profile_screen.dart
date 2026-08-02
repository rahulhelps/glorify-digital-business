import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:global_earn/features/profile/presentation/bloc/profile_event.dart';
import 'package:global_earn/features/profile/presentation/bloc/profile_state.dart';
import 'package:global_earn/features/profile/presentation/widgets/profile_bottom_action.dart';
import 'package:global_earn/features/profile/presentation/widgets/profile_edit_form.dart';
import 'package:global_earn/features/profile/presentation/widgets/profile_header.dart';
import 'package:global_earn/features/profile/presentation/widgets/profile_stats_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(LoadProfile());
        final userState = context.read<UserBloc>().state;
        if (userState is UserLoaded) {
          _nameController.text = userState.user.name;
          _phoneController.text = userState.user.phone;
          _bioController.text = userState.user.bio ?? '';
          _dateOfBirth = userState.user.dateOfBirth;
          if (_dateOfBirth != null) {
            _dobController.text = DateFormat('dd-MM-yyyy').format(_dateOfBirth!);
          } else {
            _dobController.text = '';
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<UserBloc, UserState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, userState) {
          if (userState is! UserLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userState.user;

          return Stack(
            children: [
              // ── Scrollable content ───────────────────────────────────────
              SingleChildScrollView(
                // No horizontal/top padding — banner fills edge-to-edge
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Gradient banner (edge-to-edge) ─────────────────────
                    ProfileHeader(user: user),

                    // ── White rounded-top card — overlaps banner ──────
                    Container(
                      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                      decoration: const BoxDecoration(
                        color: Colors.white, // Pure White (#FFFFFF)
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.all(AppSizes.marginMobile),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Affiliate ID / Join date — subtle info row
                          const ProfileStatsRow(),

                          const SizedBox(height: AppSizes.spacingXl),

                          // Personal info form (heading + fields)
                          ProfileEditForm(
                            user: user,
                            nameController: _nameController,
                            phoneController: _phoneController,
                            bioController: _bioController,
                            dobController: _dobController,
                            selectedDateOfBirth: _dateOfBirth,
                            onTapDateOfBirth: _pickDateOfBirth,
                          ),

                          const SizedBox(height: AppSizes.spacingXl),

                          // Profile strength card
                          // ProfileCompletionCard(user: user),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sticky bottom action button ──────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ProfileBottomAction(
                  onUpdate: () {
                    context.read<ProfileBloc>().add(
                      UpdateProfile(
                        uid: user.uid,
                        name: _nameController.text,
                        phone: _phoneController.text,
                        bio: _bioController.text,
                        dateOfBirth: _dateOfBirth,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
