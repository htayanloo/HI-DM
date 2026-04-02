import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/download_message.dart';
import 'download_manager_provider.dart';

/// Real-time data for a single active download (kept in memory, not DB).
class LiveDownloadData {
  final double speed;
  final int downloadedBytes;
  final int totalBytes;
  final String status;
  final Map<int, LiveSegmentData> segments;
  final DateTime lastUpdate;

  const LiveDownloadData({
    this.speed = 0,
    this.downloadedBytes = 0,
    this.totalBytes = -1,
    this.status = 'queued',
    this.segments = const {},
    required this.lastUpdate,
  });

  LiveDownloadData copyWith({
    double? speed,
    int? downloadedBytes,
    int? totalBytes,
    String? status,
    Map<int, LiveSegmentData>? segments,
  }) =>
      LiveDownloadData(
        speed: speed ?? this.speed,
        downloadedBytes: downloadedBytes ?? this.downloadedBytes,
        totalBytes: totalBytes ?? this.totalBytes,
        status: status ?? this.status,
        segments: segments ?? this.segments,
        lastUpdate: DateTime.now(),
      );
}

/// Real-time data for a single segment/connection.
class LiveSegmentData {
  final int index;
  final int downloadedBytes;
  final String status; // pending, downloading, completed, error

  const LiveSegmentData({
    required this.index,
    this.downloadedBytes = 0,
    this.status = 'pending',
  });
}

/// Holds live state for ALL active downloads. Updated from engine events.
class LiveDownloadStateNotifier extends StateNotifier<Map<int, LiveDownloadData>> {
  StreamSubscription<DownloadEvent>? _subscription;

  LiveDownloadStateNotifier() : super({});

  void listen(Stream<DownloadEvent> events) {
    _subscription?.cancel();
    _subscription = events.listen(_handleEvent);
  }

  void _handleEvent(DownloadEvent event) {
    final id = event.downloadId;

    switch (event.type) {
      case DownloadEventType.progress:
        final current = state[id] ?? LiveDownloadData(lastUpdate: DateTime.now());
        state = {
          ...state,
          id: current.copyWith(
            downloadedBytes: event.data['downloadedBytes'] as int,
            totalBytes: event.data['totalBytes'] as int,
          ),
        };
        break;

      case DownloadEventType.speed:
        final current = state[id] ?? LiveDownloadData(lastUpdate: DateTime.now());
        state = {
          ...state,
          id: current.copyWith(speed: event.data['bytesPerSecond'] as double),
        };
        break;

      case DownloadEventType.statusChange:
        final current = state[id] ?? LiveDownloadData(lastUpdate: DateTime.now());
        final status = event.data['status'] as String;
        if (status == 'completed' || status == 'error') {
          // Remove from live state when done
          final newState = Map<int, LiveDownloadData>.from(state);
          newState.remove(id);
          state = newState;
        } else {
          state = {
            ...state,
            id: current.copyWith(status: status),
          };
        }
        break;

      case DownloadEventType.segmentUpdate:
        final current = state[id] ?? LiveDownloadData(lastUpdate: DateTime.now());
        final segIndex = event.data['segmentIndex'] as int;
        final segBytes = event.data['downloadedBytes'] as int;
        final segStatus = event.data['status'] as String;

        final newSegments = Map<int, LiveSegmentData>.from(current.segments);
        newSegments[segIndex] = LiveSegmentData(
          index: segIndex,
          downloadedBytes: segBytes,
          status: segStatus,
        );

        state = {
          ...state,
          id: current.copyWith(segments: newSegments),
        };
        break;

      case DownloadEventType.fileInfo:
        final current = state[id] ?? LiveDownloadData(lastUpdate: DateTime.now());
        state = {
          ...state,
          id: current.copyWith(
            totalBytes: event.data['totalSize'] as int,
          ),
        };
        break;

      default:
        break;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider for live download state.
final liveDownloadStateProvider =
    StateNotifierProvider<LiveDownloadStateNotifier, Map<int, LiveDownloadData>>((ref) {
  final notifier = LiveDownloadStateNotifier();
  final manager = ref.watch(downloadManagerProvider);
  notifier.listen(manager.events);
  return notifier;
});

/// Get live data for a specific download.
final liveDownloadDataProvider =
    Provider.family<LiveDownloadData?, int>((ref, downloadId) {
  final allLive = ref.watch(liveDownloadStateProvider);
  return allLive[downloadId];
});
