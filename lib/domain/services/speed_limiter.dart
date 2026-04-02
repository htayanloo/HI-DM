import 'dart:async';

/// Async token bucket rate limiter for download speed throttling.
/// Thread-safe: multiple connections can call [consumeAsync] concurrently.
class SpeedLimiter {
  int _bytesPerSecond;
  double _tokens;
  DateTime _lastRefill;
  bool _enabled;

  SpeedLimiter({
    int bytesPerSecond = 0,
    bool enabled = false,
  })  : _bytesPerSecond = bytesPerSecond,
        _enabled = enabled,
        _tokens = bytesPerSecond.toDouble(),
        _lastRefill = DateTime.now();

  bool get enabled => _enabled && _bytesPerSecond > 0;

  int get bytesPerSecond => _bytesPerSecond;

  void update({int? bytesPerSecond, bool? enabled}) {
    if (bytesPerSecond != null) {
      _bytesPerSecond = bytesPerSecond;
      _tokens = bytesPerSecond.toDouble();
    }
    if (enabled != null) _enabled = enabled;
    _lastRefill = DateTime.now();
  }

  /// Async consume — actually waits if tokens are insufficient.
  /// Call this from each connection before writing a chunk.
  Future<void> consumeAsync(int bytes) async {
    if (!enabled) return;

    _refill();

    if (_tokens >= bytes) {
      _tokens -= bytes;
      return;
    }

    // Not enough tokens — calculate wait time
    final deficit = bytes - _tokens;
    final waitMs = (deficit / _bytesPerSecond * 1000).ceil();
    _tokens = 0;

    // Actually wait
    if (waitMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: waitMs));
    }

    // Refill after wait and consume
    _refill();
    _tokens -= bytes.clamp(0, _tokens.toInt()).toDouble();
  }

  /// Sync consume — returns wait time in ms. Legacy API.
  int consume(int bytes) {
    if (!enabled) return 0;

    _refill();

    if (_tokens >= bytes) {
      _tokens -= bytes;
      return 0;
    }

    final deficit = bytes - _tokens;
    final waitMs = (deficit / _bytesPerSecond * 1000).ceil();
    _tokens = 0;
    return waitMs;
  }

  /// Get the maximum chunk size for smooth throttling.
  int get recommendedChunkSize {
    if (!enabled) return 64 * 1024; // 64KB
    // Smaller chunks = smoother throttling. Aim for ~20 chunks/sec.
    return (_bytesPerSecond / 20).clamp(1024, 32 * 1024).toInt();
  }

  void _refill() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRefill).inMicroseconds / 1000000.0;
    _lastRefill = now;

    _tokens += elapsed * _bytesPerSecond;
    // Cap at 1 second burst
    if (_tokens > _bytesPerSecond) {
      _tokens = _bytesPerSecond.toDouble();
    }
  }
}
