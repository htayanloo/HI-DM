class SizeFormatter {
  static String format(int bytes) {
    if (bytes < 0) return 'Unknown';
    if (bytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    var size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    if (i == 0) return '${size.toInt()} ${suffixes[i]}';
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  static String formatCompact(int bytes) {
    if (bytes < 0) return '?';
    if (bytes == 0) return '0';

    const suffixes = ['B', 'K', 'M', 'G', 'T'];
    var i = 0;
    var size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    if (i == 0) return '${size.toInt()}${suffixes[i]}';
    return '${size.toStringAsFixed(1)}${suffixes[i]}';
  }
}
