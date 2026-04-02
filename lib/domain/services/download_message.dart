// Messages exchanged between the main isolate and download isolates.

enum DownloadCommand {
  start,
  pause,
  resume,
  cancel,
  updateSpeedLimit,
}

enum DownloadEventType {
  progress,
  speed,
  statusChange,
  segmentUpdate,
  error,
  log,
  fileInfo,
  completed,
}

/// Command sent FROM main isolate TO download isolate.
class DownloadCommandMessage {
  final DownloadCommand command;
  final Map<String, dynamic>? data;

  const DownloadCommandMessage(this.command, {this.data});
}

/// Event sent FROM download isolate TO main isolate.
class DownloadEvent {
  final int downloadId;
  final DownloadEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  DownloadEvent({
    required this.downloadId,
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Factory constructors for common events
  factory DownloadEvent.progress({
    required int downloadId,
    required int downloadedBytes,
    required int totalBytes,
  }) =>
      DownloadEvent(
        downloadId: downloadId,
        type: DownloadEventType.progress,
        data: {
          'downloadedBytes': downloadedBytes,
          'totalBytes': totalBytes,
        },
      );

  factory DownloadEvent.speed({
    required int downloadId,
    required double bytesPerSecond,
  }) =>
      DownloadEvent(
        downloadId: downloadId,
        type: DownloadEventType.speed,
        data: {'bytesPerSecond': bytesPerSecond},
      );

  factory DownloadEvent.statusChange({
    required int downloadId,
    required String status,
  }) =>
      DownloadEvent(
        downloadId: downloadId,
        type: DownloadEventType.statusChange,
        data: {'status': status},
      );

  factory DownloadEvent.segmentUpdate({
    required int downloadId,
    required int segmentIndex,
    required int downloadedBytes,
    required String status,
  }) =>
      DownloadEvent(
        downloadId: downloadId,
        type: DownloadEventType.segmentUpdate,
        data: {
          'segmentIndex': segmentIndex,
          'downloadedBytes': downloadedBytes,
          'status': status,
        },
      );

  factory DownloadEvent.error({
    required int downloadId,
    required String message,
    bool fatal = false,
  }) =>
      DownloadEvent(
        downloadId: downloadId,
        type: DownloadEventType.error,
        data: {'message': message, 'fatal': fatal},
      );

  factory DownloadEvent.log({
    required int downloadId,
    required String message,
  }) =>
      DownloadEvent(
        downloadId: downloadId,
        type: DownloadEventType.log,
        data: {'message': message},
      );

  factory DownloadEvent.fileInfo({
    required int downloadId,
    required String fileName,
    required int totalSize,
    required bool supportsRange,
  }) =>
      DownloadEvent(
        downloadId: downloadId,
        type: DownloadEventType.fileInfo,
        data: {
          'fileName': fileName,
          'totalSize': totalSize,
          'supportsRange': supportsRange,
        },
      );

  factory DownloadEvent.completed({required int downloadId}) =>
      DownloadEvent(
        downloadId: downloadId,
        type: DownloadEventType.completed,
        data: {},
      );
}

/// Initial configuration sent to a download isolate on spawn.
class DownloadIsolateConfig {
  final int downloadId;
  final String url;
  final String savePath;
  final String fileName;
  final String tempDirectory;
  final int threadCount;
  final Map<String, String> headers;
  final String? proxyConfigJson;
  final int? speedLimitBytesPerSecond;
  final int connectionTimeoutSeconds;
  final int maxRetries;
  final int retryDelaySeconds;
  // Resume data
  final int? existingTotalSize;
  final List<SegmentResumeData>? resumeSegments;

  const DownloadIsolateConfig({
    required this.downloadId,
    required this.url,
    required this.savePath,
    required this.fileName,
    required this.tempDirectory,
    this.threadCount = 8,
    this.headers = const {},
    this.proxyConfigJson,
    this.speedLimitBytesPerSecond,
    this.connectionTimeoutSeconds = 30,
    this.maxRetries = 5,
    this.retryDelaySeconds = 5,
    this.existingTotalSize,
    this.resumeSegments,
  });

  Map<String, dynamic> toMap() => {
    'downloadId': downloadId,
    'url': url,
    'savePath': savePath,
    'fileName': fileName,
    'tempDirectory': tempDirectory,
    'threadCount': threadCount,
    'headers': headers,
    'proxyConfigJson': proxyConfigJson,
    'speedLimitBytesPerSecond': speedLimitBytesPerSecond,
    'connectionTimeoutSeconds': connectionTimeoutSeconds,
    'maxRetries': maxRetries,
    'retryDelaySeconds': retryDelaySeconds,
    'existingTotalSize': existingTotalSize,
    'resumeSegments': resumeSegments?.map((s) => s.toMap()).toList(),
  };

  factory DownloadIsolateConfig.fromMap(Map<String, dynamic> map) => DownloadIsolateConfig(
    downloadId: map['downloadId'] as int,
    url: map['url'] as String,
    savePath: map['savePath'] as String,
    fileName: map['fileName'] as String,
    tempDirectory: map['tempDirectory'] as String,
    threadCount: map['threadCount'] as int? ?? 8,
    headers: (map['headers'] as Map<String, dynamic>?)?.cast<String, String>() ?? {},
    proxyConfigJson: map['proxyConfigJson'] as String?,
    speedLimitBytesPerSecond: map['speedLimitBytesPerSecond'] as int?,
    connectionTimeoutSeconds: map['connectionTimeoutSeconds'] as int? ?? 30,
    maxRetries: map['maxRetries'] as int? ?? 5,
    retryDelaySeconds: map['retryDelaySeconds'] as int? ?? 5,
    existingTotalSize: map['existingTotalSize'] as int?,
    resumeSegments: (map['resumeSegments'] as List<dynamic>?)
        ?.map((s) => SegmentResumeData.fromMap(s as Map<String, dynamic>))
        .toList(),
  );
}

/// Data needed to resume a segment.
class SegmentResumeData {
  final int segmentIndex;
  final int startByte;
  final int endByte;
  final int downloadedBytes;
  final String tempFilePath;

  const SegmentResumeData({
    required this.segmentIndex,
    required this.startByte,
    required this.endByte,
    required this.downloadedBytes,
    required this.tempFilePath,
  });

  Map<String, dynamic> toMap() => {
    'segmentIndex': segmentIndex,
    'startByte': startByte,
    'endByte': endByte,
    'downloadedBytes': downloadedBytes,
    'tempFilePath': tempFilePath,
  };

  factory SegmentResumeData.fromMap(Map<String, dynamic> map) => SegmentResumeData(
    segmentIndex: map['segmentIndex'] as int,
    startByte: map['startByte'] as int,
    endByte: map['endByte'] as int,
    downloadedBytes: map['downloadedBytes'] as int,
    tempFilePath: map['tempFilePath'] as String,
  );
}
