import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:global_earn/core/constants/app_strings.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:global_earn/features/auth/presentation/bloc/auth_state.dart';
import 'package:global_earn/core/network/bloc/connectivity_bloc.dart';
import 'package:global_earn/core/network/bloc/connectivity_state.dart';
import 'package:global_earn/features/app_update/presentation/bloc/app_update_bloc.dart';
import 'package:global_earn/features/app_update/presentation/bloc/app_update_event.dart';
import 'package:global_earn/features/app_update/presentation/bloc/app_update_state.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotsController;
  bool _minSplashTimeElapsed = false;
  bool _hasNavigated = false;
  String _versionText = '';

  @override
  void initState() {
    super.initState();
    _initVersion();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _minSplashTimeElapsed = true;
      _checkAndNavigate();
    });
  }

  Future<void> _initVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _versionText = 'v${info.version} (${info.buildNumber})';
      });
    }
  }

  void _checkAndNavigate() {
    if (_hasNavigated || !_minSplashTimeElapsed) return;
    
    final connState = context.read<ConnectivityBloc>().state;
    final updateState = context.read<AppUpdateBloc>().state;

    if (connState is ConnectivityConnected) {
      if (updateState is AppUpdateUpToDate || updateState is AppUpdateError) {
        _hasNavigated = true;
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      } else if (updateState is AppUpdateRequired) {
        _hasNavigated = true;
        _showForceUpdateDialog(updateState.downloadUrl);
      }
    }
  }

  void _showForceUpdateDialog(String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '🔴 আপডেট প্রয়োজন!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'অ্যাপের একটি নতুন সংস্করণ রিলিজ হয়েছে। অ্যাপটি ব্যবহার করা চালিয়ে যেতে দয়া করে এখনই আপডেট করে নিন।',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final url = Uri.parse(downloadUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text(
                        'এখনই আপডেট করুন',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<ConnectivityBloc, ConnectivityState>(
            listener: (context, state) {
              if (state is ConnectivityDisconnected) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please check your internet connection.'),
                    backgroundColor: Colors.redAccent,
                    duration: Duration(days: 365),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is ConnectivityConnected) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                if (context.read<AppUpdateBloc>().state is AppUpdateInitial) {
                  context.read<AppUpdateBloc>().add(const CheckAppUpdate());
                }
                _checkAndNavigate();
              }
            },
          ),
          BlocListener<AppUpdateBloc, AppUpdateState>(
            listener: (context, state) {
              if (state is AppUpdateUpToDate || state is AppUpdateError || state is AppUpdateRequired) {
                _checkAndNavigate();
              }
            },
          ),
        ],
        child: Scaffold(
        backgroundColor: AppColors.primaryDark, // Matches the native splash exact background
      body: Stack(
        children: [
          // Background Gradient - Fade in seamlessly over the primary color
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            builder: (context, opacity, child) {
              return Opacity(
                opacity: opacity,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              );
            },
          ),
          
          // Foreground Content
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo — instantly visible, then pulses
                      ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/images/golden_power_logo2.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1.0, 1.0), // Starts at 1.0 to seamlessly match native splash
                            end: const Offset(1.08, 1.08),
                            duration: 1000.ms,
                            curve: Curves.easeInOut,
                          ),

                      const SizedBox(height: 32),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          AppStrings.appNameShort.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppStrings.appNameShort.length > 15 ? 20 : 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: AppStrings.appNameShort.length > 15 ? 1.2 : 3,
                            height: 1.3,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0, delay: 300.ms),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'DIGITAL BUSINESS PLATFORM',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                    ],
                  ),
                ),

                // Bottom loading dots
                Positioned(
                  bottom: 48,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LoadingDots(controller: _dotsController)
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 400.ms),
                      if (_versionText.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _versionText,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ).animate().fadeIn(delay: 1000.ms),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ), // closes TweenAnimationBuilder
    ), // closes Scaffold
    ); // closes MultiBlocListener
  }
}

class _LoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            // Stagger each dot by 200ms
            final staggeredValue = ((controller.value + index * 0.25) % 1.0);
            final scale =
                0.6 +
                0.4 *
                    (staggeredValue < 0.5
                        ? staggeredValue * 2
                        : (1.0 - staggeredValue) * 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
