import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/presentation/widgets/startup_gate.dart';

const readyApp = MaterialApp(home: Scaffold(body: Text('Downloads ready')));

void main() {
  testWidgets(
    'renders while startup waits and does not wait for notification permission',
    (tester) async {
      final startup = Completer<void>();
      final notifications = Completer<void>();
      await tester.pumpWidget(
        StartupGate(
          initialize: () => startup.future,
          initializeNotifications: () => notifications.future,
          child: readyApp,
        ),
      );
      expect(find.text('Starting HI-DM…'), findsOneWidget);
      startup.complete();
      await tester.pump();
      await tester.pump();
      expect(find.text('Downloads ready'), findsOneWidget);
      // A platform permission callback that never returns cannot hide the app.
      await tester.pump(const Duration(seconds: 11));
      expect(find.text('Downloads ready'), findsOneWidget);
      expect(tester.takeException(), isNull);
      notifications.complete();
      await tester.pump();
    },
  );

  testWidgets('startup failure shows its error and can be retried', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      StartupGate(
        initialize: () async {
          if (++attempts == 1) throw StateError('Database is unavailable');
        },
        initializeNotifications: () async {},
        child: readyApp,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unable to start HI-DM'), findsOneWidget);
    expect(find.textContaining('Database is unavailable'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Downloads ready'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('notification initialization failure leaves the app usable', (
    tester,
  ) async {
    await tester.pumpWidget(
      StartupGate(
        initialize: () async {},
        initializeNotifications: () =>
            throw StateError('Permission unavailable'),
        child: readyApp,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Downloads ready'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
