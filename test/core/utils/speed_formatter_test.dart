import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/core/utils/speed_formatter.dart';

void main() {
  group('SpeedFormatter', () {
    group('format', () {
      test('formats zero speed', () {
        expect(SpeedFormatter.format(0), '0 B/s');
      });

      test('formats bytes per second', () {
        expect(SpeedFormatter.format(500), '500 B/s');
      });

      test('formats KB/s', () {
        expect(SpeedFormatter.format(1024), '1.00 KB/s');
      });

      test('formats MB/s', () {
        expect(SpeedFormatter.format(1048576), '1.00 MB/s');
      });

      test('formats negative as zero', () {
        expect(SpeedFormatter.format(-100), '0 B/s');
      });
    });

    group('formatEta', () {
      test('formats null as --:--', () {
        expect(SpeedFormatter.formatEta(null), '--:--');
      });

      test('formats seconds', () {
        expect(SpeedFormatter.formatEta(const Duration(seconds: 45)), '45s');
      });

      test('formats minutes and seconds', () {
        expect(SpeedFormatter.formatEta(const Duration(minutes: 5, seconds: 30)), '5m 30s');
      });

      test('formats hours', () {
        expect(SpeedFormatter.formatEta(const Duration(hours: 2, minutes: 15, seconds: 10)), '2h 15m 10s');
      });
    });
  });
}
