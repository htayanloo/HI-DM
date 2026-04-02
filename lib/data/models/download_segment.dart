class DownloadSegment {
  final int? id;
  final int downloadItemId;
  final int startByte;
  final int endByte;
  final int downloadedBytes;
  final String status; // pending, downloading, completed, error
  final String tempFilePath;

  const DownloadSegment({
    this.id,
    required this.downloadItemId,
    required this.startByte,
    required this.endByte,
    this.downloadedBytes = 0,
    this.status = 'pending',
    this.tempFilePath = '',
  });

  int get totalBytes => endByte - startByte + 1;
  double get progress => totalBytes > 0 ? downloadedBytes / totalBytes : 0;
  bool get isCompleted => status == 'completed';

  DownloadSegment copyWith({
    int? id,
    int? downloadItemId,
    int? startByte,
    int? endByte,
    int? downloadedBytes,
    String? status,
    String? tempFilePath,
  }) => DownloadSegment(
    id: id ?? this.id,
    downloadItemId: downloadItemId ?? this.downloadItemId,
    startByte: startByte ?? this.startByte,
    endByte: endByte ?? this.endByte,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    status: status ?? this.status,
    tempFilePath: tempFilePath ?? this.tempFilePath,
  );
}
