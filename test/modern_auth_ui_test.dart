import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ==========================================
// 1. WIDGET IMPLEMENTATIONS
// ==========================================

/// Reusable Modern Authentication Text Field
class ModernAuthTextField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextEditingController? controller;

  const ModernAuthTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.controller,
  });

  @override
  State<ModernAuthTextField> createState() => _ModernAuthTextFieldState();
}

class _ModernAuthTextFieldState extends State<ModernAuthTextField> {
  bool _isFocused = false;
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: _isObscured,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: Icon(
              widget.icon,
              color: _isFocused ? const Color(0xFF1565C0) : Colors.grey.shade500,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable Premium Gradient Button
class GradientPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const GradientPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], // Deep to Light Blue
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A subtle gradient text widget for premium typography
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText({
    super.key,
    required this.text,
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

/// The refactored white login container
class PremiumLoginContainer extends StatelessWidget {
  const PremiumLoginContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Wrap in SingleChildScrollView to prevent RenderFlex overflow when keyboard opens
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 2. Improved Typography with Gradient Title
            const GradientText(
              text: 'নিরাপদ লগইন প্যানেল',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'আপনার অ্যাকাউন্টে প্রবেশ করতে নিচে তথ্য দিন',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            
            const SizedBox(height: 36), // Increased vertical rhythm
            
            // 3. Extracted Modern Text Fields
            const ModernAuthTextField(
              hint: 'ইমেইল বা মোবাইল নম্বর',
              icon: Icons.person_outline_rounded,
            ),
            
            const SizedBox(height: 20),
            
            const ModernAuthTextField(
              hint: 'পাসওয়ার্ড',
              icon: Icons.lock_outline_rounded,
              obscureText: true,
            ),
            
            const SizedBox(height: 36),
            
            // 4. Premium Gradient Button
            GradientPrimaryButton(
              label: 'প্রবেশ করুন',
              onPressed: () {
                debugPrint('Login Button Pressed');
              },
            ),
            
            // Extra padding to ensure scroll clearance
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. STRICT UNIT/WIDGET TESTS
// ==========================================

void main() {
  testWidgets('Renders all premium login UI elements correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          // Wrap in a layout that mocks a device screen
          body: Align(
            alignment: Alignment.bottomCenter,
            child: PremiumLoginContainer(),
          ),
        ),
      ),
    );

    // Assert Typography
    expect(find.text('নিরাপদ লগইন প্যানেল'), findsOneWidget);
    expect(find.text('আপনার অ্যাকাউন্টে প্রবেশ করতে নিচে তথ্য দিন'), findsOneWidget);

    // Assert ModernAuthTextFields
    expect(find.byType(ModernAuthTextField), findsNWidgets(2));
    expect(find.text('ইমেইল বা মোবাইল নম্বর'), findsOneWidget);
    expect(find.text('পাসওয়ার্ড'), findsOneWidget);

    // Assert GradientPrimaryButton
    expect(find.byType(GradientPrimaryButton), findsOneWidget);
    expect(find.text('প্রবেশ করুন'), findsOneWidget);

    debugPrint('✅ Output: PremiumLoginContainer rendered successfully with modern fields and button.');
  });

  testWidgets('Prevents RenderFlex overflow on small screens (simulated keyboard pop-up)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          // Force a very small height (e.g., when keyboard is open on an iPhone SE)
          body: SizedBox(
            height: 200, 
            width: 320,
            child: PremiumLoginContainer(),
          ),
        ),
      ),
    );

    // If it wasn't wrapped in a SingleChildScrollView, this would throw a RenderFlex overflow.
    // We expect no exceptions.
    expect(tester.takeException(), isNull);
    
    // Check that we can scroll
    final scrollable = find.byType(SingleChildScrollView);
    expect(scrollable, findsOneWidget);
    
    debugPrint('✅ Output: PremiumLoginContainer safely handles tight vertical constraints (keyboard popup) without overflow errors.');
  });
}
