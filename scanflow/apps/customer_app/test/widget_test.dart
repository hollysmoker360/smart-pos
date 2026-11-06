import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixx_smartpos/main.dart';

void main() {
  testWidgets('App renders store selection screen initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrixxApp()));

    expect(find.text('ScanFlow'), findsOneWidget);
  });
}
