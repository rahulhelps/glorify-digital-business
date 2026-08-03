import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_strings.dart';
import 'package:global_earn/core/utils/validators.dart';
import 'package:global_earn/features/auth/presentation/bloc/login_bloc.dart';
import 'package:global_earn/features/auth/presentation/bloc/login_event.dart';
import 'package:global_earn/features/auth/presentation/bloc/login_state.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_event.dart';
import 'package:global_earn/core/services/notification_service.dart';

// UI REDESIGN: FinTech aesthetic
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_isSubmitting) return; 
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isSubmitting = true);
    context.read<LoginBloc>().add(
      LoginSubmitted(
        identifier: _identifierCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: AppColors.primaryContainer),
            SizedBox(width: 8),
            Text(
              'পাসওয়ার্ড রিসেট',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'আপনার ইমেইল ঠিকানা দিন। আমরা পাসওয়ার্ড রিসেট লিংক পাঠাব।',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'example@email.com',
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.primaryContainer,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryContainer,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'বাতিল',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          BlocBuilder<LoginBloc, LoginState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              final isLoading = state is ForgotPasswordLoading;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final email = emailController.text.trim();
                        if (email.isEmpty) return;
                        context.read<LoginBloc>().add(
                          ForgotPasswordRequested(email: email),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'রিসেট লিংক পাঠান',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.read<UserBloc>().add(UserLoadedEvent(state.user));
          NotificationService.updateUserFcmToken(state.user.uid);
          NotificationService.subscribeToAllUsersTopic();
          NotificationService.setupTokenRefreshListener(state.user.uid);
          context.go('/home');
        } else if (state is LoginFailure) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is ForgotPasswordSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ রিসেট লিংক পাঠানো হয়েছে! ইমেইল চেক করুন'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 4),
            ),
          );
        } else if (state is ForgotPasswordError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D47A1), // Deep navy background to bleed into the top area
        body: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // ── TOP SECTION (Logo) ──
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/login.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // ── BOTTOM SECTION (White Card) ──
              Expanded(
                flex: 7,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32), // Strict modern 32 radius
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    // Ensures we pad enough for keyboard popups seamlessly
                    padding: EdgeInsets.fromLTRB(
                      24, 
                      40, 
                      24, 
                      MediaQuery.of(context).viewInsets.bottom + 40
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Left aligned title & subtitle
                        children: [
                          Text(
                            AppStrings.loginTitle,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A), // Slate 900
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.loginSubtitle,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: const Color(0xFF64748B), // Slate 500
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Mobile Number / Email
                          ModernFinTechTextField(
                            hint: AppStrings.loginMobileOrEmailHint,
                            icon: Icons.alternate_email_rounded,
                            controller: _identifierCtrl,
                            validator: Validators.mobileOrEmail,
                          ),
                          const SizedBox(height: 20),

                          // Password (Includes Forgot Password button inside as a suffix)
                          ModernFinTechTextField(
                            hint: AppStrings.loginPasswordHint,
                            icon: Icons.lock_outline_rounded,
                            controller: _passwordCtrl,
                            obscureText: true,
                            validator: Validators.password,
                            suffixAction: TextButton(
                              onPressed: () => _showForgotPasswordDialog(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppStrings.loginForgotPassword,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),

                          // Login Button
                          BlocBuilder<LoginBloc, LoginState>(
                            buildWhen: (previous, current) => previous != current,
                            builder: (context, state) {
                              final isLoading = state is LoginLoading || _isSubmitting;
                              return GradientFinTechButton(
                                isLoading: isLoading,
                                onPressed: isLoading ? null : () => _submit(context),
                                label: AppStrings.loginCta,
                              );
                            },
                          ),
                          const SizedBox(height: 32),

                          // Register Link
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                ),
                                children: [
                                  const TextSpan(text: AppStrings.loginNoAccount),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: () => context.go('/register'),
                                      child: Text(
                                        AppStrings.loginRegisterLink,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GradientFinTechButton
// ─────────────────────────────────────────────────────────────────────────────

class GradientFinTechButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;

  const GradientFinTechButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
  });

  @override
  State<GradientFinTechButton> createState() => _GradientFinTechButtonState();
}

class _GradientFinTechButtonState extends State<GradientFinTechButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) setState(() => _pressed = true);
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: double.infinity,
          height: 56, // Slightly taller for modern aesthetic
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: widget.isLoading
                  ? const LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onPressed,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: widget.isLoading
                        ? Row(
                            key: const ValueKey('loading'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'অপেক্ষা করুন...',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            key: const ValueKey('label'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.label,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ModernFinTechTextField
// ─────────────────────────────────────────────────────────────────────────────

class ModernFinTechTextField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? suffixAction;
  final TextInputType keyboardType;

  const ModernFinTechTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.suffixAction,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<ModernFinTechTextField> createState() => _ModernFinTechTextFieldState();
}

class _ModernFinTechTextFieldState extends State<ModernFinTechTextField> {
  bool _isObscured = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _isObscured,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF94A3B8), // Slate 400
            fontSize: 15,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: _isFocused ? AppColors.primaryContainer : const Color(0xFF94A3B8),
            size: 22,
          ),
          suffixIcon: (widget.obscureText || widget.suffixAction != null)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.suffixAction != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: widget.suffixAction!,
                      ),
                    if (widget.obscureText)
                      IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: const Color(0xFF94A3B8),
                          size: 22,
                        ),
                        onPressed: () => setState(() => _isObscured = !_isObscured),
                      ),
                    const SizedBox(width: 4), // right padding
                  ],
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100, // Soft gray filled background
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
          // Completely borderless at rest
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          // Vibrant border only on focus
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryContainer,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
          ),
          errorMaxLines: 2,
        ),
      ),
    );
  }
}
