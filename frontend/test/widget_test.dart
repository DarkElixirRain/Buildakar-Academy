import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildacad/main.dart';

void main() {
  testWidgets('app boots with the main shell', (tester) async {
    await tester.pumpWidget(const BuildAcadApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
