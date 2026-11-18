import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/presentation/widgets/selectable_download_list.dart';

void main() {
  Set<int> selected = {};

  Future<void> showList(
    WidgetTester tester, {
    List<int> ids = const [1, 2, 3],
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SelectableDownloadList(
                itemIds: ids,
                selectedIds: selected,
                onSelectionChanged: (value) => setState(() => selected = value),
                itemBuilder: (_, index) => SizedBox(
                  height: 80,
                  child: Center(child: Text('Row ${ids[index]}')),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  setUp(() => selected = {});

  testWidgets('select all targets the filtered list and can be cleared', (
    tester,
  ) async {
    selected = {99}; // A selection hidden by the current filter.
    await showList(tester, ids: [2, 3]);
    await tester.tap(find.text('Select all'));
    await tester.pump();
    expect(selected, {2, 3});
    expect(find.text('2 selected'), findsOneWidget);
    await tester.tap(find.text('Clear selection'));
    await tester.pump();
    expect(selected, isEmpty);
  });

  testWidgets('dragging the mouse selects intersecting rows', (tester) async {
    await showList(tester);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    final first = tester.getRect(find.text('Row 1'));
    final last = tester.getRect(find.text('Row 3'));
    await gesture.down(first.topLeft - const Offset(20, 0));
    await gesture.moveTo(last.bottomRight + const Offset(20, 0));
    await tester.pump();
    expect(selected, {1, 2, 3});
    await gesture.up();
    await tester.pump();
    expect(selected, {1, 2, 3});
  });

  testWidgets('Ctrl+A and Cmd+A select all; Escape clears selection', (
    tester,
  ) async {
    await showList(tester);
    await tester.tap(find.text('Row 1'));
    await tester.pump();
    for (final modifier in [
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.metaLeft,
    ]) {
      await tester.sendKeyDownEvent(modifier);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(modifier);
      await tester.pump();
      expect(selected, {1, 2, 3});
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(selected, isEmpty);
    }
  });
}
