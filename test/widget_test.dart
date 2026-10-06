import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dm/app.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    // HiDMApp installs a global ErrorWidget.builder error boundary;
    // restore it so the test binding's post-test check passes.
    final originalErrorWidgetBuilder = ErrorWidget.builder;

    await tester.pumpWidget(
      const ProviderScope(child: HiDMApp()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // The custom titlebar renders the app name on the home screen.
    expect(find.text('HI-DM'), findsWidgets);

    ErrorWidget.builder = originalErrorWidgetBuilder;
  });
}
