import 'dart:convert';

import 'download_segment.dart';
import 'proxy_config.dart';

class DownloadItem {
  final int? id;
  final String url;
  final String fileName;
  final String savePath;
  final int totalSize; // bytes, -1 if unknown
  final int downloadedSize; // bytes
  final String status; // from DownloadStatus enum name
  final int threadCount;
  final double speed; // bytes/sec
  final int speedLimit; // bytes/sec, 0 = unlimited
  final DateTime dateAdded;
  final DateTime? dateCompleted;
  final String? category;
  final int? queueId;
  final String? errorMessage;
  final int retryCount;
  final Map<String, String> headers; // custom headers (cookies, referer, auth)
  final ProxyConfig? proxy;
  final List<DownloadSegment> segments;

  const DownloadItem({
    this.id,
    required this.url,
    required this.fileName,
    required this.savePath,
    this.totalSize = -1,
    this.downloadedSize = 0,
    this.status = 'queued',
    this.threadCount = 8,
    this.speed = 0,
    this.speedLimit = 0,
    required this.dateAdded,
    this.dateCompleted,
    this.category,
    this.queueId,
    this.errorMessage,
    this.retryCount = 0,
    this.headers = const {},
    this.proxy,
    this.segments = const [],
  });

  double get progress => totalSize > 0 ? downloadedSize / totalSize : 0;
  bool get isCompleted => status == 'completed';
  bool get isActive => status == 'downloading' || status == 'connecting';
  bool get hasSpeedLimit => speedLimit > 0;

  Duration? get eta {
    if (speed <= 0 || totalSize <= 0) return null;
    final remaining = totalSize - downloadedSize;
    return Duration(seconds: (remaining / speed).ceil());
  }

  String get headersJson => jsonEncode(headers);
  static Map<String, String> headersFromJson(String json) {
    if (json.isEmpty) return {};
    return (jsonDecode(json) as Map<String, dynamic>).map((k, v) => MapEntry(k, v.toString()));
  }

  DownloadItem copyWith({
    int? id,
    String? url,
    String? fileName,
    String? savePath,
    int? totalSize,
    int? downloadedSize,
    String? status,
    int? threadCount,
    double? speed,
    int? speedLimit,
    DateTime? dateAdded,
    DateTime? dateCompleted,
    String? category,
    int? queueId,
    String? errorMessage,
    int? retryCount,
    Map<String, String>? headers,
    ProxyConfig? proxy,
    List<DownloadSegment>? segments,
  }) => DownloadItem(
    id: id ?? this.id,
    url: url ?? this.url,
    fileName: fileName ?? this.fileName,
    savePath: savePath ?? this.savePath,
    totalSize: totalSize ?? this.totalSize,
    downloadedSize: downloadedSize ?? this.downloadedSize,
    status: status ?? this.status,
    threadCount: threadCount ?? this.threadCount,
    speed: speed ?? this.speed,
    speedLimit: speedLimit ?? this.speedLimit,
    dateAdded: dateAdded ?? this.dateAdded,
    dateCompleted: dateCompleted ?? this.dateCompleted,
    category: category ?? this.category,
    queueId: queueId ?? this.queueId,
    errorMessage: errorMessage ?? this.errorMessage,
    retryCount: retryCount ?? this.retryCount,
    headers: headers ?? this.headers,
    proxy: proxy ?? this.proxy,
    segments: segments ?? this.segments,
  );
}
