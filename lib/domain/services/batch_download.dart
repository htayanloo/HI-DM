import '../../core/utils/url_utils.dart';
import 'download_manager.dart';

/// Service for batch download operations.
class BatchDownloadService {
  final DownloadManager _manager;

  BatchDownloadService(this._manager);

  /// Download a list of URLs to the same directory.
  Future<List<int>> downloadUrls({
    required List<String> urls,
    required String savePath,
    int? threadCount,
    Map<String, String> headers = const {},
  }) async {
    final ids = <int>[];
    for (final url in urls) {
      final id = await _manager.addDownload(
        url: url,
        savePath: savePath,
        threadCount: threadCount,
        headers: headers,
        startImmediately: true,
      );
      ids.add(id);
    }
    return ids;
  }

  /// Generate batch URLs from a pattern and download them.
  Future<List<int>> downloadPattern({
    required String pattern,
    required String savePath,
    int? threadCount,
    Map<String, String> headers = const {},
  }) async {
    final urls = UrlUtils.generateBatchUrls(pattern);
    return downloadUrls(
      urls: urls,
      savePath: savePath,
      threadCount: threadCount,
      headers: headers,
    );
  }

  /// Import URLs from text (one per line) and download them.
  Future<List<int>> downloadFromText({
    required String text,
    required String savePath,
    int? threadCount,
    Map<String, String> headers = const {},
  }) async {
    final urls = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && UrlUtils.isValidUrl(l))
        .toList();
    return downloadUrls(
      urls: urls,
      savePath: savePath,
      threadCount: threadCount,
      headers: headers,
    );
  }
}
