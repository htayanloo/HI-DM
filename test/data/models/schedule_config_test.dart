import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/data/models/schedule_config.dart';

void main() {
  group('ScheduleConfig', () {
    test('JSON round-trip with all fields', () {
      final config = ScheduleConfig(
        startAt: DateTime(2024, 1, 15, 8, 0),
        stopAt: DateTime(2024, 1, 15, 22, 0),
        recurring: true,
        daysOfWeek: [1, 3, 5],
        syncInterval: const Duration(hours: 2),
      );

      final json = config.encode();
      final decoded = ScheduleConfig.decode(json);

      expect(decoded.startAt, config.startAt);
      expect(decoded.stopAt, config.stopAt);
      expect(decoded.recurring, true);
      expect(decoded.daysOfWeek, [1, 3, 5]);
      expect(decoded.syncInterval, const Duration(hours: 2));
    });

    test('JSON round-trip with minimal fields', () {
      const config = ScheduleConfig();
      final json = config.encode();
      final decoded = ScheduleConfig.decode(json);

      expect(decoded.startAt, null);
      expect(decoded.stopAt, null);
      expect(decoded.recurring, false);
      expect(decoded.daysOfWeek, isEmpty);
      expect(decoded.syncInterval, null);
    });

    test('copyWith preserves unmodified fields', () {
      final config = ScheduleConfig(
        startAt: DateTime(2024, 1, 15, 8, 0),
        recurring: true,
        daysOfWeek: [1, 2, 3],
      );
      final updated = config.copyWith(recurring: false);
      expect(updated.startAt, config.startAt);
      expect(updated.recurring, false);
      expect(updated.daysOfWeek, [1, 2, 3]);
    });
  });
}
