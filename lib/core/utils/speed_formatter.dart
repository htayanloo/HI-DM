class SpeedFormatter {
  static String format(double bytesPerSecond) {
    if (bytesPerSecond <= 0) return '0 B/s';

    const suffixes = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    var i = 0;
    var speed = bytesPerSecond;

    while (speed >= 1024 && i < suffixes.length - 1) {
      speed /= 1024;
      i++;
    }

    if (i == 0) return '${speed.toInt()} ${suffixes[i]}';
    return '${speed.toStringAsFixed(2)} ${suffixes[i]}';
  }

  static String formatEta(Duration? duration) {
    if (duration == null) return '--:--';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}
