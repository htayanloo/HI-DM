import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dm/app.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: HiDMApp()),
    );
    expect(find.text('HI-DM v1.0.0'), findsOneWidget);
  });
}
