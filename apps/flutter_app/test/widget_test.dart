import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trixx_smartpos/main.dart';
import 'package:trixx_smartpos/providers/shopping_provider.dart';

void main() {
  testWidgets('App renders store selection screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ShoppingProvider(),
        child: const TrixxApp(),
      ),
    );

    expect(find.text('TRIXX SmartPOS - Select Supermarket'), findsOneWidget);
  });
}
