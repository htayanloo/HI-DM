class UrlUtils {
  static final _urlPattern = RegExp(
    r'^(https?|ftp)://[^\s/$.?#].[^\s]*$',
    caseSensitive: false,
  );

  static bool isValidUrl(String url) {
    return _urlPattern.hasMatch(url.trim());
  }

  static String? extractProtocol(String url) {
    try {
      return Uri.parse(url).scheme;
    } catch (_) {
      return null;
    }
  }

  static String? extractHost(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return null;
    }
  }

  static List<String> generateBatchUrls(String pattern) {
    // Supports [start-end] pattern, e.g., image_[001-100].jpg
    final regex = RegExp(r'\[(\d+)-(\d+)\]');
    final match = regex.firstMatch(pattern);
    if (match == null) return [pattern];

    final start = int.parse(match.group(1)!);
    final end = int.parse(match.group(2)!);
    final padLength = match.group(1)!.length;

    final urls = <String>[];
    for (var i = start; i <= end; i++) {
      final number = i.toString().padLeft(padLength, '0');
      urls.add(pattern.replaceFirst(regex, number));
    }
    return urls;
  }
}
