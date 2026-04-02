import 'package:path/path.dart' as p;

class FileUtils {
  static String getExtension(String fileName) {
    return p.extension(fileName).toLowerCase();
  }

  static String getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final name = pathSegments.last;
        if (name.contains('.')) return Uri.decodeFull(name);
      }
      return 'download_${DateTime.now().millisecondsSinceEpoch}';
    } catch (_) {
      return 'download_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  static String sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  static String getUniqueFileName(String fileName, int counter) {
    final base = p.basenameWithoutExtension(fileName);
    final ext = p.extension(fileName);
    return '$base($counter)$ext';
  }
}
