import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnhub/main.dart';

void main() {
  testWidgets('app boots with the main shell', (tester) async {
    await tester.pumpWidget(const LearnHubApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
