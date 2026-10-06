import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dm/data/datasources/database.dart' hide DownloadItem;
import 'package:flutter_dm/data/models/app_settings.dart';
import 'package:flutter_dm/data/models/download_item.dart';
import 'package:flutter_dm/data/repositories/settings_repository.dart';
import 'package:flutter_dm/presentation/providers/category_providers.dart';
import 'package:flutter_dm/presentation/providers/download_providers.dart';
import 'package:flutter_dm/presentation/screens/home/home_screen.dart';
import 'package:flutter_dm/presentation/widgets/download_tile.dart';

/// The list providers are stubbed with in-memory streams.
///
/// Drift's `.watch()` streams schedule a deferred `Timer.run` for every
/// notification, which flutter_test reports as a pending timer when the test
/// ends — so the real stream sources are replaced at the provider boundary.
List<Override> _overrides(AppDatabase db, List<DownloadItem> items) => [
      databaseProvider.overrideWithValue(db),
      allDownloadsProvider.overrideWith((ref) => Stream.value(items)),
      allCategoriesProvider.overrideWith((ref) => Stream.value(const [])),
    ];

DownloadItem _item(
  String name, {
  required DateTime added,
  int totalSize = 0,
}) =>
    DownloadItem(
      url: 'https://example.com/$name',
      fileName: name,
      savePath: '/tmp',
      dateAdded: added,
      totalSize: totalSize,
      status: 'completed',
    );

/// Unmounts the tree and flushes a frame so no framework or drift timer
/// survives into the test teardown.
Future<void> _finish(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets('toolbar has a sort control and defaults to oldest first',
      (WidgetTester tester) async {
    final original = ErrorWidget.builder;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await SettingsRepository(db)
        .setBoolValue(AppSettings.clipboardMonitoring, false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(db, [
          _item('old.bin', added: DateTime(2026, 1, 1)),
          _item('new.bin', added: DateTime(2026, 6, 1)),
        ]),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The sort control is present in the toolbar and reports the active
    // order via its tooltip.
    expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
    expect(find.byTooltip('Sort: Oldest first'), findsOneWidget);

    // Default order: oldest added first.
    final order = tester
        .widgetList<DownloadTile>(find.byType(DownloadTile))
        .map((t) => t.item.fileName)
        .toList();
    expect(order, ['old.bin', 'new.bin']);

    ErrorWidget.builder = original;
    await _finish(tester);
  });

  testWidgets('choosing an option from the sort menu reorders the list',
      (WidgetTester tester) async {
    final original = ErrorWidget.builder;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await SettingsRepository(db)
        .setBoolValue(AppSettings.clipboardMonitoring, false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(db, [
          _item('small.bin', added: DateTime(2026, 1, 1), totalSize: 100),
          _item('big.bin', added: DateTime(2026, 6, 1), totalSize: 999999),
        ]),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    List<String> order() => tester
        .widgetList<DownloadTile>(find.byType(DownloadTile))
        .map((t) => t.item.fileName)
        .toList();

    expect(order(), ['small.bin', 'big.bin']); // oldest first

    await tester.tap(find.byIcon(Icons.sort_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Largest first'));
    await tester.pumpAndSettle();

    expect(order(), ['big.bin', 'small.bin'],
        reason: 'the sort menu must reorder the list');
    expect(find.byTooltip('Sort: Largest first'), findsOneWidget,
        reason: 'the button must show the active order');

    ErrorWidget.builder = original;
    await _finish(tester);
  });

  testWidgets('sort choice is persisted so it survives a relaunch',
      (WidgetTester tester) async {
    final original = ErrorWidget.builder;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await SettingsRepository(db)
        .setBoolValue(AppSettings.clipboardMonitoring, false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(db, [
          _item('a.bin', added: DateTime(2026, 1, 1)),
          _item('b.bin', added: DateTime(2026, 6, 1)),
        ]),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byIcon(Icons.sort_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Newest first'));
    await tester.pumpAndSettle();

    // The provider reflects the choice immediately...
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    expect(container.read(sortOrderProvider), 'lifo');

    // ...and it was written to settings so it survives a relaunch.
    final saved =
        await SettingsRepository(db).getValue(AppSettings.listSortOrder);
    expect(saved, 'lifo');

    ErrorWidget.builder = original;
    await _finish(tester);
  });
}
