import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_strings.dart';
import 'package:global_earn/core/utils/validators.dart';
import 'package:global_earn/features/auth/presentation/bloc/register_bloc.dart';
import 'package:global_earn/features/auth/presentation/bloc/register_event.dart';
import 'package:global_earn/features/auth/presentation/bloc/register_state.dart';
import 'package:global_earn/features/auth/presentation/widgets/info_card.dart';
import 'package:global_earn/features/auth/presentation/widgets/privacy_checkbox.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_event.dart';
import 'package:global_earn/core/services/notification_service.dart';
import 'package:global_earn/features/auth/presentation/screens/login_screen.dart'; // Import reusable FinTech widgets

// UI REDESIGN: FinTech aesthetic
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _affiliateCtrl = TextEditingController();
  bool _privacyAccepted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _affiliateCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_isSubmitting) return; // hard guard against double-tap
    if (_formKey.currentState?.validate() != true) return;
    if (!_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the privacy policy.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        name: _nameCtrl.text.trim(),
        phone: _mobileCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        // Empty → auto-use default code (validator already enforced non-empty above)
        referredBy: _affiliateCtrl.text.trim().isEmpty
            ? '123456'
            : _affiliateCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Registration successful!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          context.read<UserBloc>().add(UserLoadedEvent(state.user));
          
          // ── FCM: Update token on register success ──
          NotificationService.updateUserFcmToken(state.user.uid);
          NotificationService.subscribeToAllUsersTopic();
          NotificationService.setupTokenRefreshListener(state.user.uid);
          // ────────────────────────────────────────

          context.go('/home');
        } else if (state is RegisterFailure) {
          if (mounted) {
            setState(() => _isSubmitting = false);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D47A1), // Deep navy background
        body: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  // ── TOP SECTION (Logo) ──
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/login.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── BOTTOM SECTION (White Card) ──
                  Expanded(
                    flex: 8,
                    child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      24, 
                      40, 
                      24, 
                      MediaQuery.of(context).viewInsets.bottom + 40
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.registerTitle,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Full Name
                          ModernFinTechTextField(
                            hint: AppStrings.fullNameHint,
                            icon: Icons.person_outline_rounded,
                            controller: _nameCtrl,
                            validator: Validators.name,
                          ),
                          const SizedBox(height: 16),

                          // Mobile
                          ModernFinTechTextField(
                            hint: AppStrings.mobileHint,
                            icon: Icons.phone_android_rounded,
                            controller: _mobileCtrl,
                            keyboardType: TextInputType.phone,
                            validator: Validators.mobile,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          ModernFinTechTextField(
                            hint: 'ইমেইল অ্যাড্রেস',
                            icon: Icons.alternate_email_rounded,
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.mobileOrEmail,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          ModernFinTechTextField(
                            hint: AppStrings.passwordHint,
                            icon: Icons.lock_outline_rounded,
                            controller: _passwordCtrl,
                            obscureText: true,
                            validator: Validators.password,
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          ModernFinTechTextField(
                            hint: AppStrings.confirmPasswordHint,
                            icon: Icons.verified_user_outlined,
                            controller: _confirmPasswordCtrl,
                            obscureText: true,
                            validator: (v) => Validators.confirmPassword(
                              v,
                              _passwordCtrl.text,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Referral Code
                          ModernFinTechTextField(
                            hint: 'রেফার কোড লিখুন',
                            icon: Icons.card_membership_outlined,
                            controller: _affiliateCtrl,
                            validator: (v) {
                              final code = v?.trim() ?? '';
                              if (code.isEmpty) {
                                return 'রেফার কোড দেওয়া বাধ্যতামূলক। রেফার কোড না থাকলে ব্যবহার করুন।';
                              }
                              if (code.length < 4) {
                                return 'অবৈধ রেফার কোড। ন্যূনতম ৪ অক্ষর প্রয়োজন।';
                              }
                              return null;
                            },
                          ),
                          // Referral helper text
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 13,
                                  color: AppColors.primaryContainer,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFF64748B),
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'রেফার কোড বাধ্যতামূলক। '
                                          ,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Privacy Checkbox
                          PrivacyCheckbox(
                            onChanged: (v) => setState(() => _privacyAccepted = v),
                          ),
                          const SizedBox(height: 32),

                          // Register Button
                          BlocBuilder<RegisterBloc, RegisterState>(
                            buildWhen: (previous, current) =>
                                previous != current,
                            builder: (context, state) {
                              final isLoading =
                                  state is RegisterLoading || _isSubmitting;
                              return GradientFinTechButton(
                                isLoading: isLoading,
                                onPressed: isLoading
                                    ? null
                                    : () => _submit(context),
                                label: AppStrings.registerCta,
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Login Link
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                ),
                                children: [
                                  const TextSpan(text: AppStrings.registerHaveAccount),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: () => context.go('/login'),
                                      child: Text(
                                        AppStrings.registerLoginLink,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Info Card
                          const InfoCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ── BACK BUTTON ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/login');
                }
              },
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
