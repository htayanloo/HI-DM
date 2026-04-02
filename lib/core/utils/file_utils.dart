import 'package:path/path.dart' as p;

class FileUtils {
  static String getExtension(String fileName) {
    return p.extension(fileName).toLowerCase();
  }

  /// Extract filename from URL. Handles:
  /// - Direct filenames: /path/file.zip
  /// - Query format hints: ?format=mkv&quality=4
  /// - Content-Disposition (handled separately in SegmentManager)
  /// - Fallback: uses last path segment + format from query
  static String getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

      String baseName = '';
      String? extension;

      // Try to get filename from path
      if (pathSegments.isNotEmpty) {
        final last = Uri.decodeFull(pathSegments.last);
        if (last.contains('.') && !last.startsWith('.')) {
          // Has extension: file.zip, movie.mkv
          return _sanitizeBasic(last);
        }
        // No extension — use as base name
        baseName = last;
      }

      // Try to detect extension from query parameters
      final query = uri.queryParameters;

      // Common format parameters: format, type, ext, f
      for (final key in ['format', 'type', 'ext', 'f']) {
        if (query.containsKey(key)) {
          final fmt = query[key]!.toLowerCase();
          if (_isKnownExtension(fmt)) {
            extension = fmt;
            break;
          }
        }
      }

      // Try to detect from other query hints
      if (extension == null) {
        // Check if any query value looks like a filename
        for (final value in query.values) {
          if (value.contains('.') && value.length < 100) {
            final ext = p.extension(value).toLowerCase();
            if (ext.length > 1 && ext.length < 8) {
              return _sanitizeBasic(value);
            }
          }
        }
      }

      // Build filename
      if (baseName.isEmpty) {
        baseName = 'download_${DateTime.now().millisecondsSinceEpoch}';
      }

      if (extension != null) {
        return _sanitizeBasic('$baseName.$extension');
      }

      return _sanitizeBasic(baseName);
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

  static String _sanitizeBasic(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  static bool _isKnownExtension(String ext) {
    const known = {
      // Video
      'mp4', 'mkv', 'avi', 'mov', 'wmv', 'webm', 'flv', 'm4v', 'ts', '3gp',
      // Audio
      'mp3', 'wav', 'flac', 'aac', 'ogg', 'wma', 'm4a',
      // Documents
      'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'rtf',
      // Archives
      'zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz',
      // Images
      'jpg', 'jpeg', 'png', 'gif', 'svg', 'webp', 'bmp',
      // Programs
      'exe', 'msi', 'dmg', 'deb', 'rpm', 'apk', 'appimage',
      // Other
      'iso', 'img', 'bin', 'torrent', 'srt', 'sub', 'ass',
    };
    return known.contains(ext.toLowerCase());
  }
}
