import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dm/data/datasources/database.dart';
import 'package:flutter_dm/presentation/providers/download_providers.dart';
import 'package:flutter_dm/presentation/screens/settings/settings_screen.dart';

/// Pumps the settings screen against a fresh in-memory database so the
/// DB-backed cards render without touching the real app database.
Future<void> pumpSettings(WidgetTester tester) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: SettingsScreen()),
    ),
  );
  // Let the settings FutureProvider resolve against the in-memory DB.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('Settings screen renders with sidebar navigation', (WidgetTester tester) async {
    final originalErrorWidgetBuilder = ErrorWidget.builder;

    await pumpSettings(tester);

    // Sidebar sections are present
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Connection'), findsOneWidget);
    expect(find.text('Downloads'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);

    // Default section (General) card renders — proving the card layout works
    expect(find.text('Startup & Background'), findsOneWidget);
    expect(find.text('Behavior'), findsOneWidget);
    expect(find.text('Performance'), findsOneWidget);

    ErrorWidget.builder = originalErrorWidgetBuilder;
  });

  testWidgets('Settings sections switch when sidebar items are tapped', (WidgetTester tester) async {
    final originalErrorWidgetBuilder = ErrorWidget.builder;

    await pumpSettings(tester);

    await tester.tap(find.text('Downloads'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Save Locations'), findsOneWidget);
    expect(find.text('Disk Cleanup'), findsOneWidget);
    expect(find.text('Default save path'), findsOneWidget);

    await tester.tap(find.text('Advanced'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Speed & Notifications'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    await tester.tap(find.text('Connection'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Time & Retries'), findsOneWidget);
    expect(find.text('Proxy'), findsOneWidget);

    ErrorWidget.builder = originalErrorWidgetBuilder;
  });
}
