import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ==========================================
// 1. WIDGET IMPLEMENTATION
// ==========================================

class CustomNoticeBanner extends StatelessWidget {
  final String noticeText;
  final Color borderColor;
  final Color badgeColor;
  final Color textColor;
  
  const CustomNoticeBanner({
    super.key,
    required this.noticeText,
    // Using a vibrant primary blue as requested
    this.borderColor = const Color(0xFF1565C0), 
    this.badgeColor = const Color(0xFF1565C0),
    this.textColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Graceful handling of empty strings
    if (noticeText.trim().isEmpty) {
      return const SizedBox.shrink(); 
    }

    // 2. Responsive Container
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 52), // Increased height / 1.5x taller
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 2.0), // Vibrant border
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 3. Distinct "নোটিশ" Badge
          IntrinsicWidth(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(9),
                  bottomLeft: Radius.circular(9),
                  bottomRight: Radius.circular(20), // Angled badge style
                ),
              ),
              child: const Text(
                'নোটিশ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 4. Notice Text Area (Expanded prevents RenderFlex overflow on narrow screens)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0).copyWith(right: 12.0),
              // 5. Handling extremely long strings
              child: Text(
                noticeText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Safe fallback for long text
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. STRICT UNIT/WIDGET TESTS
// ==========================================

void main() {
  testWidgets('Renders properly with text', (WidgetTester tester) async {
    const testText = 'আলহামদুলিল্লাহ প্রজেক্ট চালু রয়েছে';
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomNoticeBanner(noticeText: testText),
        ),
      ),
    );

    // Assert "নোটিশ" badge is present
    expect(find.text('নোটিশ'), findsOneWidget);
    
    // Assert notice text is present
    expect(find.text(testText), findsOneWidget);
    
    debugPrint('✅ Output: CustomNoticeBanner(noticeText: "$testText") rendered successfully with badge and text.');
  });

  testWidgets('Gracefully handles empty string (renders SizedBox.shrink)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomNoticeBanner(noticeText: ''),
        ),
      ),
    );

    // Should not find the badge or any text
    expect(find.text('নোটিশ'), findsNothing);
    
    debugPrint('✅ Output: CustomNoticeBanner(noticeText: "") handled gracefully (hidden without layout shifts).');
  });

  testWidgets('Handles extremely long text without RenderFlex overflow', (WidgetTester tester) async {
    const longText = 'This is a very long notice string that should definitely trigger a TextOverflow if it is not wrapped inside an Expanded or Flexible widget which handles constraints properly.';
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300, // Force a narrow screen to test flex constraints
            child: CustomNoticeBanner(noticeText: longText),
          ),
        ),
      ),
    );

    // If there was an overflow exception, tester.takeException() would catch it.
    // We expect no exceptions.
    expect(tester.takeException(), isNull);
    expect(find.text('নোটিশ'), findsOneWidget);
    
    debugPrint('✅ Output: CustomNoticeBanner handled extremely long text on narrow screen safely without RenderFlex errors.');
  });
}
