import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/data/models/download_item.dart';
import 'package:flutter_dm/domain/services/download_manager.dart';

DownloadItem _item(String name, DateTime added, {int totalSize = 0}) {
  return DownloadItem(
    url: 'https://example.com/$name',
    fileName: name,
    savePath: '/tmp',
    dateAdded: added,
    totalSize: totalSize,
    status: 'queued',
  );
}

void main() {
  group('sortQueueBy', () {
    final t0 = DateTime(2026, 1, 1);
    final t1 = DateTime(2026, 1, 2);
    final t2 = DateTime(2026, 1, 3);

    List<DownloadItem> base() => [
          _item('first.zip', t0, totalSize: 300),
          _item('second.zip', t1, totalSize: 100),
          _item('third.zip', t2, totalSize: 200),
        ];

    test('fifo (default) orders oldest first', () {
      final list = base();
      sortQueueBy(list, 'fifo');
      expect(list.map((e) => e.fileName), ['first.zip', 'second.zip', 'third.zip']);
    });

    test('unknown order falls back to fifo', () {
      final list = base();
      sortQueueBy(list, 'definitely-not-a-real-order');
      expect(list.map((e) => e.fileName), ['first.zip', 'second.zip', 'third.zip']);
    });

    test('lifo orders newest first', () {
      final list = base();
      sortQueueBy(list, 'lifo');
      expect(list.map((e) => e.fileName), ['third.zip', 'second.zip', 'first.zip']);
    });

    test('largest orders by size descending', () {
      final list = base();
      sortQueueBy(list, 'largest');
      expect(list.map((e) => e.fileName), ['first.zip', 'third.zip', 'second.zip']);
    });

    test('smallest orders by size ascending', () {
      final list = base();
      sortQueueBy(list, 'smallest');
      expect(list.map((e) => e.fileName), ['second.zip', 'third.zip', 'first.zip']);
    });

    test('name orders alphabetically case-insensitively', () {
      final list = [
        _item('Banana.zip', t0),
        _item('apple.zip', t1),
        _item('Cherry.zip', t2),
      ];
      sortQueueBy(list, 'name');
      expect(list.map((e) => e.fileName), ['apple.zip', 'Banana.zip', 'Cherry.zip']);
    });

    test('empty list is left alone', () {
      final list = <DownloadItem>[];
      sortQueueBy(list, 'fifo');
      expect(list, isEmpty);
    });
  });
}
