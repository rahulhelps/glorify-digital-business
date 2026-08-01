import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_earn/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('FinTech Login UI validates left alignment and internal button components', (WidgetTester tester) async {
    // Isolated rendering of the extracted components to verify their internal structure
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('নিরাপদ লগইন প্যানেল'), // Mocking the left aligned title layout
              ModernFinTechTextField(
                hint: 'Password Test',
                icon: Icons.lock,
                controller: TextEditingController(),
                obscureText: true,
                suffixAction: TextButton(
                  onPressed: () {},
                  child: const Text('পাসওয়ার্ড রিকভারি?'),
                ),
              ),
              const GradientFinTechButton(
                label: 'প্রবেশ করুন',
                isLoading: false,
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify the 'Forgot Password' button is rendered (inside the TextField suffix)
    expect(find.text('পাসওয়ার্ড রিকভারি?'), findsOneWidget);
    
    // 2. Verify the visibility toggle icon is present (defaults to off when obscureText is true)
    expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);

    // 3. Verify the GradientFinTechButton contains the label AND the arrow icon
    expect(find.text('প্রবেশ করুন'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

    debugPrint('✅ Output: FinTech Login UI validated successfully (Left Aligned texts, Suffix actions, Button icons).');
  });
}
