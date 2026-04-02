import 'dart:math';

import 'package:dio/dio.dart';

import '../../core/utils/file_utils.dart';

/// Result of analyzing a URL before downloading.
class UrlAnalysis {
  final int contentLength;
  final bool supportsRange;
  final String? suggestedFileName;
  final String? mimeType;
  final Map<String, String> responseHeaders;

  const UrlAnalysis({
    required this.contentLength,
    required this.supportsRange,
    this.suggestedFileName,
    this.mimeType,
    this.responseHeaders = const {},
  });
}

/// Represents a byte-range segment for downloading.
class SegmentInfo {
  final int index;
  final int startByte;
  final int endByte;

  const SegmentInfo({
    required this.index,
    required this.startByte,
    required this.endByte,
  });

  int get totalBytes => endByte - startByte + 1;

  SegmentInfo copyWith({int? index, int? startByte, int? endByte}) =>
      SegmentInfo(
        index: index ?? this.index,
        startByte: startByte ?? this.startByte,
        endByte: endByte ?? this.endByte,
      );
}

class SegmentManager {
  final Dio _dio;

  SegmentManager(this._dio);

  /// Analyze URL via HEAD request to determine file info and range support.
  Future<UrlAnalysis> analyzeUrl(
    String url, {
    Map<String, String> headers = const {},
    int timeoutSeconds = 30,
  }) async {
    try {
      final response = await _dio.head<void>(
        url,
        options: Options(
          headers: headers,
          followRedirects: true,
          maxRedirects: 10,
          receiveTimeout: Duration(seconds: timeoutSeconds),
          sendTimeout: Duration(seconds: timeoutSeconds),
        ),
      );

      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });

      final contentLength = _parseContentLength(response.headers);
      final supportsRange = _checkRangeSupport(response.headers);
      final suggestedFileName = _extractFileName(response.headers, url);
      final mimeType = response.headers.value('content-type');

      return UrlAnalysis(
        contentLength: contentLength,
        supportsRange: supportsRange,
        suggestedFileName: suggestedFileName,
        mimeType: mimeType,
        responseHeaders: responseHeaders,
      );
    } on DioException catch (e) {
      // If HEAD fails, try a GET with range 0-0 to probe
      if (e.type == DioExceptionType.badResponse) {
        return _probeWithGet(url, headers: headers, timeoutSeconds: timeoutSeconds);
      }
      rethrow;
    }
  }

  /// Probe URL with a GET range request if HEAD is not supported.
  Future<UrlAnalysis> _probeWithGet(
    String url, {
    Map<String, String> headers = const {},
    int timeoutSeconds = 30,
  }) async {
    final probeHeaders = Map<String, String>.from(headers);
    probeHeaders['Range'] = 'bytes=0-0';

    final response = await _dio.get<void>(
      url,
      options: Options(
        headers: probeHeaders,
        followRedirects: true,
        maxRedirects: 10,
        receiveTimeout: Duration(seconds: timeoutSeconds),
        sendTimeout: Duration(seconds: timeoutSeconds),
        // Don't download the body
        responseType: ResponseType.stream,
      ),
    );

    // Close the stream immediately
    final stream = response.data as ResponseBody?;
    await stream?.stream.drain<void>();

    final responseHeaders = <String, String>{};
    response.headers.forEach((name, values) {
      responseHeaders[name] = values.join(', ');
    });

    final supportsRange = response.statusCode == 206;
    var contentLength = -1;

    if (supportsRange) {
      // Parse Content-Range: bytes 0-0/total
      final contentRange = response.headers.value('content-range');
      if (contentRange != null) {
        final match = RegExp(r'bytes\s+\d+-\d+/(\d+)').firstMatch(contentRange);
        if (match != null) {
          contentLength = int.parse(match.group(1)!);
        }
      }
    } else {
      contentLength = _parseContentLength(response.headers);
    }

    return UrlAnalysis(
      contentLength: contentLength,
      supportsRange: supportsRange,
      suggestedFileName: _extractFileName(response.headers, url),
      mimeType: response.headers.value('content-type'),
      responseHeaders: responseHeaders,
    );
  }

  /// Create N segments for a file of the given total size.
  /// If totalSize is unknown (-1) or range not supported, returns a single segment.
  List<SegmentInfo> createSegments(int totalSize, int threadCount) {
    if (totalSize <= 0 || threadCount <= 1) {
      return [
        SegmentInfo(
          index: 0,
          startByte: 0,
          endByte: totalSize > 0 ? totalSize - 1 : -1,
        ),
      ];
    }

    // Don't create segments smaller than 256KB
    const minSegmentSize = 256 * 1024;
    final effectiveThreads = min(
      threadCount,
      max(1, totalSize ~/ minSegmentSize),
    );

    final segmentSize = totalSize ~/ effectiveThreads;
    final segments = <SegmentInfo>[];

    for (var i = 0; i < effectiveThreads; i++) {
      final start = i * segmentSize;
      final end = (i == effectiveThreads - 1) ? totalSize - 1 : (i + 1) * segmentSize - 1;
      segments.add(SegmentInfo(index: i, startByte: start, endByte: end));
    }

    return segments;
  }

  /// Dynamically rebalance segments when one finishes early.
  /// Returns new segment assignments if a split is beneficial, null otherwise.
  ///
  /// [completedIndex] - index of the segment that just completed
  /// [segmentProgress] - map of segment index -> downloaded bytes for active segments
  /// [segmentInfos] - current segment definitions
  List<SegmentInfo>? dynamicRebalance({
    required int completedIndex,
    required Map<int, int> segmentProgress,
    required List<SegmentInfo> segmentInfos,
  }) {
    // Find the segment with the most remaining bytes
    int? slowestIndex;
    int maxRemaining = 0;

    for (final entry in segmentProgress.entries) {
      if (entry.key == completedIndex) continue;
      final segment = segmentInfos[entry.key];
      final remaining = segment.totalBytes - entry.value;
      if (remaining > maxRemaining) {
        maxRemaining = remaining;
        slowestIndex = entry.key;
      }
    }

    // Only split if the remaining work is substantial (> 512KB)
    if (slowestIndex == null || maxRemaining < 512 * 1024) return null;

    final slowest = segmentInfos[slowestIndex];
    final downloaded = segmentProgress[slowestIndex] ?? 0;
    final currentPosition = slowest.startByte + downloaded;
    final midpoint = currentPosition + ((slowest.endByte - currentPosition) ~/ 2);

    // Slowest keeps downloading up to midpoint
    // New segment (reusing completedIndex) takes midpoint+1 to end
    final updatedSegments = List<SegmentInfo>.from(segmentInfos);
    updatedSegments[slowestIndex] = slowest.copyWith(endByte: midpoint);

    // Reuse the completed segment's slot for the new range
    updatedSegments[completedIndex] = SegmentInfo(
      index: completedIndex,
      startByte: midpoint + 1,
      endByte: slowest.endByte,
    );

    return updatedSegments;
  }

  int _parseContentLength(Headers headers) {
    final cl = headers.value('content-length');
    if (cl == null) return -1;
    return int.tryParse(cl) ?? -1;
  }

  bool _checkRangeSupport(Headers headers) {
    final acceptRanges = headers.value('accept-ranges');
    return acceptRanges != null && acceptRanges.toLowerCase() != 'none';
  }

  String? _extractFileName(Headers headers, String url) {
    // Try Content-Disposition first
    final disposition = headers.value('content-disposition');
    if (disposition != null) {
      // Try filename*=UTF-8''encoded_name
      final starMatch = RegExp(r"filename\*\s*=\s*UTF-8''(.+?)(?:;|$)", caseSensitive: false)
          .firstMatch(disposition);
      if (starMatch != null) {
        return FileUtils.sanitizeFileName(Uri.decodeFull(starMatch.group(1)!.trim()));
      }

      // Try filename="name" or filename=name
      final match = RegExp(r'filename\s*=\s*"?([^";\n]+)"?', caseSensitive: false)
          .firstMatch(disposition);
      if (match != null) {
        return FileUtils.sanitizeFileName(match.group(1)!.trim());
      }
    }

    // Fall back to URL
    return FileUtils.sanitizeFileName(FileUtils.getFileNameFromUrl(url));
  }
}
