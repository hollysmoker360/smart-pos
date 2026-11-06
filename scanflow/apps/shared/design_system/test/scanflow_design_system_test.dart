import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow_design_system/scanflow_design_system.dart';

void main() {
  testWidgets('empty state uses shared content and action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ScanFlowTheme.light,
        home: const Scaffold(
          body: ScanFlowEmptyState(
            icon: Icons.storefront,
            title: 'No branches yet',
            message: 'Create a branch to get started.',
            action: Text('Add branch'),
          ),
        ),
      ),
    );

    expect(find.text('No branches yet'), findsOneWidget);
    expect(find.text('Create a branch to get started.'), findsOneWidget);
    expect(find.text('Add branch'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(ScanFlowEmptyState)))
          .scaffoldBackgroundColor,
      ScanFlowColors.background,
    );
  });
}
