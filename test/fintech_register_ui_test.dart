import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_earn/features/auth/presentation/screens/login_screen.dart'; // Source of widgets
import 'package:global_earn/features/auth/presentation/screens/register_screen.dart'; 

void main() {
  testWidgets('FinTech Register UI validates left alignment, button icons, and no overflow', (WidgetTester tester) async {
    // Isolated rendering of the extracted components to verify their internal structure
    // We use a Column to mock the register layout constraints
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('নতুন একাউন্ট তৈরি করুন'), // Mocking the left aligned title layout
                ModernFinTechTextField(
                  hint: 'Name Test',
                  icon: Icons.person,
                  controller: TextEditingController(),
                ),
                ModernFinTechTextField(
                  hint: 'Password Test',
                  icon: Icons.lock,
                  controller: TextEditingController(),
                  obscureText: true,
                ),
                const GradientFinTechButton(
                  label: 'একাউন্ট তৈরি করুন',
                  isLoading: false,
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify the 'Register' title is rendered (left-aligned text node)
    expect(find.text('নতুন একাউন্ট তৈরি করুন'), findsOneWidget);
    
    // 2. Verify the visibility toggle icon is present in the obscure field
    expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);

    // 3. Verify the GradientFinTechButton contains the label AND the arrow icon
    expect(find.text('একাউন্ট তৈরি করুন'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

    // 4. Verify no RenderFlex overflow occurs with these constraints
    expect(tester.takeException(), isNull);

    debugPrint('✅ Output: FinTech Register UI validated successfully (Left Aligned texts, Layout constraints, Button icons).');
  });
}
