import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/core/utils/size_formatter.dart';

void main() {
  group('SizeFormatter', () {
    group('format', () {
      test('formats 0 bytes', () {
        expect(SizeFormatter.format(0), '0 B');
      });

      test('formats bytes', () {
        expect(SizeFormatter.format(500), '500 B');
      });

      test('formats kilobytes', () {
        expect(SizeFormatter.format(1024), '1.00 KB');
      });

      test('formats megabytes', () {
        expect(SizeFormatter.format(1048576), '1.00 MB');
      });

      test('formats gigabytes', () {
        expect(SizeFormatter.format(1073741824), '1.00 GB');
      });

      test('formats negative as Unknown', () {
        expect(SizeFormatter.format(-1), 'Unknown');
      });

      test('formats partial values', () {
        expect(SizeFormatter.format(1536), '1.50 KB');
      });
    });

    group('formatCompact', () {
      test('formats 0', () {
        expect(SizeFormatter.formatCompact(0), '0');
      });

      test('formats compact KB', () {
        expect(SizeFormatter.formatCompact(1024), '1.0K');
      });

      test('formats compact MB', () {
        expect(SizeFormatter.formatCompact(1048576), '1.0M');
      });

      test('formats negative as ?', () {
        expect(SizeFormatter.formatCompact(-1), '?');
      });
    });
  });
}
