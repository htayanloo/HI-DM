enum SegmentStatus {
  pending,
  downloading,
  completed,
  error;

  String get label {
    switch (this) {
      case SegmentStatus.pending: return 'Pending';
      case SegmentStatus.downloading: return 'Downloading';
      case SegmentStatus.completed: return 'Completed';
      case SegmentStatus.error: return 'Error';
    }
  }
}
