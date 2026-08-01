import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_earn/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LifeChangeApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
