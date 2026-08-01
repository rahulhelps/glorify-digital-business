import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/home/presentation/bloc/home_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/home_event.dart';
import 'package:global_earn/features/home/presentation/bloc/home_state.dart';
import 'package:global_earn/features/home/presentation/widgets/home_hero_section.dart';
import 'package:global_earn/features/home/presentation/widgets/home_premium_card.dart';
import 'package:global_earn/features/home/presentation/widgets/home_notice_bar.dart';
import 'package:global_earn/features/home/presentation/widgets/home_unified_projects_section.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/profile/domain/repositories/profile_repository.dart';
import 'package:global_earn/features/home/presentation/widgets/verification_success_banner.dart';
import 'package:global_earn/service_locator.dart';


bool isNoticeShownThisSession = false;

class HomeScreen extends StatefulWidget {
  final bool showVerificationSuccessDialog;
  const HomeScreen({super.key, this.showVerificationSuccessDialog = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<DocumentSnapshot>? _noticeSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeBloc>().add(const HomeStarted());
        if (widget.showVerificationSuccessDialog) {
          final userState = context.read<UserBloc>().state;
          if (userState is UserLoaded) {
            _showVerificationSuccessModal(context, userState.user);
          }
        } else {
          _checkVerificationBanner();
        }
      }
    });

    _listenToNoticeStream();
  }

  void _checkVerificationBanner() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      final user = userState.user;
      if (user.hasAnyActivePlan && !user.verificationBannerShown) {
        _showVerificationBanner(user);
      }
    }
  }

  void _showVerificationBanner(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return VerificationSuccessBanner(
          user: user,
          onDismiss: () {
            Navigator.of(context).pop();
            sl<ProfileRepository>().markVerificationBannerShown(user.uid);
          },
        );
      },
    );
  }

  void _showVerificationSuccessModal(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return VerificationSuccessBanner(
          user: user,
          onDismiss: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _noticeSubscription?.cancel();
    super.dispose();
  }

  void _listenToNoticeStream() {
    try {
      _noticeSubscription = FirebaseFirestore.instance
          .doc('app_config/home_notice')
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data() as Map<String, dynamic>;
          final bool isActive = data['isActive'] ?? false;
          final String title = data['title'] ?? 'Notice';
          final String noticeText = data['noticeText'] ?? '';
          final String imageUrl = data['imageUrl'] ?? '';

          if (isActive && !isNoticeShownThisSession) {
            isNoticeShownThisSession = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _renderPremiumNoticeDialog(context, title, noticeText, imageUrl);
              }
            });
          }
        }
      }, onError: (e) {
        debugPrint('Error loading home notice stream: $e');
      });
    } catch (e) {
      debugPrint('Error setting up home notice stream: $e');
    }
  }

  void _renderPremiumNoticeDialog(BuildContext context, String title, String noticeText, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: AppColors.surface,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Linkify(
                          text: noticeText,
                          onOpen: (link) async {
                            final Uri url = Uri.parse(link.url);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6),
                          linkStyle: TextStyle(
                            color: AppColors.primary, 
                            fontWeight: FontWeight.bold, 
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'ঠিক আছে',
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) {
        if (current is UserLoaded) {
          final user = current.user;
          return user.hasAnyActivePlan && !user.verificationBannerShown;
        }
        return false;
      },
      listener: (context, state) {
        if (state is UserLoaded) {
          _showVerificationBanner(state.user);
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.coral),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.marginMobile,
            AppSizes.spacingSm,
            AppSizes.marginMobile,
            AppSizes.spacingLg,
          ),
          child: Column(
            children: const [
              HomeHeroSection(),
              HomeNoticeBar(),
              SizedBox(height: AppSizes.spacingLg),
              HomePremiumCard(),
              SizedBox(height: AppSizes.spacingLg),
              HomeUnifiedProjectsSection(),
            ],
          ),
        );
      },
    ),
    );
  }
}
