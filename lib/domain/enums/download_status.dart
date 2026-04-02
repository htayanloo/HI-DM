enum DownloadStatus {
  queued,
  connecting,
  downloading,
  paused,
  completed,
  error,
  assembling,
  merging;

  String get label {
    switch (this) {
      case DownloadStatus.queued: return 'Queued';
      case DownloadStatus.connecting: return 'Connecting';
      case DownloadStatus.downloading: return 'Downloading';
      case DownloadStatus.paused: return 'Paused';
      case DownloadStatus.completed: return 'Completed';
      case DownloadStatus.error: return 'Error';
      case DownloadStatus.assembling: return 'Assembling';
      case DownloadStatus.merging: return 'Merging';
    }
  }

  bool get isActive => this == downloading || this == connecting;
  bool get canResume => this == paused || this == error;
  bool get canPause => this == downloading || this == connecting || this == queued;
}
