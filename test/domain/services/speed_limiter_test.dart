import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/domain/services/speed_limiter.dart';

void main() {
  group('SpeedLimiter', () {
    test('disabled limiter returns 0 wait time', () {
      final limiter = SpeedLimiter(bytesPerSecond: 1024, enabled: false);
      expect(limiter.consume(512), 0);
    });

    test('enabled limiter with zero rate is not enabled', () {
      final limiter = SpeedLimiter(bytesPerSecond: 0, enabled: true);
      expect(limiter.enabled, false);
    });

    test('consume within budget returns 0', () {
      final limiter = SpeedLimiter(bytesPerSecond: 10240, enabled: true);
      expect(limiter.consume(5120), 0);
    });

    test('consume exceeding budget returns positive wait', () {
      final limiter = SpeedLimiter(bytesPerSecond: 1024, enabled: true);
      // First consume the entire bucket
      limiter.consume(1024);
      // Next consume should require waiting
      final wait = limiter.consume(512);
      expect(wait, greaterThan(0));
    });

    test('update changes rate', () {
      final limiter = SpeedLimiter(bytesPerSecond: 1024, enabled: true);
      limiter.update(bytesPerSecond: 2048);
      expect(limiter.bytesPerSecond, 2048);
    });

    test('update can enable/disable', () {
      final limiter = SpeedLimiter(bytesPerSecond: 1024, enabled: false);
      expect(limiter.enabled, false);
      limiter.update(enabled: true);
      expect(limiter.enabled, true);
    });

    test('recommendedChunkSize is reasonable', () {
      final limiter = SpeedLimiter(bytesPerSecond: 102400, enabled: true);
      final chunk = limiter.recommendedChunkSize;
      expect(chunk, greaterThanOrEqualTo(1024));
      expect(chunk, lessThanOrEqualTo(65536));
    });

    test('default chunk size when disabled', () {
      final limiter = SpeedLimiter(enabled: false);
      expect(limiter.recommendedChunkSize, 65536);
    });
  });
}
