import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';

class GrabbedLink {
  final String url;
  final String? title;
  final String type; // 'page', 'image', 'video', 'audio', 'document', 'archive', 'other'
  final int depth;
  bool selected;

  GrabbedLink({
    required this.url,
    this.title,
    required this.type,
    required this.depth,
    this.selected = true,
  });
}

class SiteGrabberConfig {
  final String startUrl;
  final int maxDepth;
  final bool sameHostOnly;
  final bool allowSubdomains;
  final Set<String> fileTypeFilters; // e.g., {'image', 'video', 'audio'}
  final int maxLinks;

  const SiteGrabberConfig({
    required this.startUrl,
    this.maxDepth = 3,
    this.sameHostOnly = true,
    this.allowSubdomains = false,
    this.fileTypeFilters = const {},
    this.maxLinks = 500,
  });
}

class SiteGrabber {
  final Dio _dio;
  bool _cancelled = false;

  SiteGrabber() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    followRedirects: true,
  ));

  void cancel() => _cancelled = true;

  Future<List<GrabbedLink>> crawl(
    SiteGrabberConfig config, {
    void Function(int pagesVisited, int linksFound)? onProgress,
  }) async {
    _cancelled = false;
    final visited = <String>{};
    final links = <GrabbedLink>[];
    final queue = Queue<_CrawlTask>();

    queue.add(_CrawlTask(url: config.startUrl, depth: 0));
    final startHost = Uri.parse(config.startUrl).host;

    while (queue.isNotEmpty && !_cancelled && links.length < config.maxLinks) {
      final task = queue.removeFirst();
      if (visited.contains(task.url) || task.depth > config.maxDepth) continue;
      visited.add(task.url);

      try {
        final response = await _dio.get<String>(task.url);
        final html = response.data ?? '';
        final foundUrls = _extractLinks(html, task.url);

        for (final foundUrl in foundUrls) {
          if (links.length >= config.maxLinks) break;

          final uri = Uri.tryParse(foundUrl);
          if (uri == null) continue;

          // Domain filtering
          if (config.sameHostOnly && !_isSameHost(uri.host, startHost, config.allowSubdomains)) {
            continue;
          }

          final type = _classifyUrl(foundUrl);

          // Type filtering
          if (config.fileTypeFilters.isNotEmpty && !config.fileTypeFilters.contains(type) && type != 'page') {
            continue;
          }

          if (type == 'page' && !visited.contains(foundUrl)) {
            queue.add(_CrawlTask(url: foundUrl, depth: task.depth + 1));
          }

          if (type != 'page') {
            links.add(GrabbedLink(
              url: foundUrl,
              type: type,
              depth: task.depth,
              selected: config.fileTypeFilters.isEmpty || config.fileTypeFilters.contains(type),
            ));
          }
        }

        onProgress?.call(visited.length, links.length);
      } catch (_) {
        // Skip failed pages
      }
    }

    return links;
  }

  List<String> _extractLinks(String html, String baseUrl) {
    final links = <String>[];
    final baseUri = Uri.parse(baseUrl);

    // Match href, src attributes
    final pattern = RegExp(r"""(?:href|src)\s*=\s*["']([^"']+)["']""", caseSensitive: false);
    for (final match in pattern.allMatches(html)) {
      final rawUrl = match.group(1);
      if (rawUrl == null || rawUrl.startsWith('#') || rawUrl.startsWith('javascript:')) continue;

      try {
        final resolved = baseUri.resolve(rawUrl);
        if (resolved.scheme == 'http' || resolved.scheme == 'https') {
          links.add(resolved.toString());
        }
      } catch (_) {}
    }

    return links;
  }

  bool _isSameHost(String host, String startHost, bool allowSubdomains) {
    if (host == startHost) return true;
    if (allowSubdomains) return host.endsWith('.$startHost');
    return false;
  }

  String _classifyUrl(String url) {
    final lower = url.toLowerCase();
    final ext = lower.split('.').last.split('?').first;

    const imageExts = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp', 'ico', 'tiff'};
    const videoExts = {'mp4', 'mkv', 'avi', 'mov', 'wmv', 'webm', 'flv', 'm4v'};
    const audioExts = {'mp3', 'wav', 'flac', 'aac', 'ogg', 'wma', 'm4a'};
    const docExts = {'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'rtf'};
    const archiveExts = {'zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz'};

    if (imageExts.contains(ext)) return 'image';
    if (videoExts.contains(ext)) return 'video';
    if (audioExts.contains(ext)) return 'audio';
    if (docExts.contains(ext)) return 'document';
    if (archiveExts.contains(ext)) return 'archive';
    if (lower.endsWith('.html') || lower.endsWith('.htm') || !ext.contains('/') && ext.length > 5) {
      return 'page';
    }
    return 'other';
  }

  void dispose() {
    _cancelled = true;
    _dio.close();
  }
}

class _CrawlTask {
  final String url;
  final int depth;
  const _CrawlTask({required this.url, required this.depth});
}
