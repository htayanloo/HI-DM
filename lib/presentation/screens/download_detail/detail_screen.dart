import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/size_formatter.dart';
import '../../../core/utils/speed_formatter.dart';
import '../../../data/models/download_item.dart';
import '../../../domain/services/download_message.dart';
import '../../providers/download_manager_provider.dart';
import '../../providers/download_providers.dart';
import '../../widgets/status_icon.dart';
import 'log_view.dart';
import 'segment_view.dart';
import 'speed_graph.dart';

class DownloadDetailScreen extends ConsumerStatefulWidget {
  final int downloadId;

  const DownloadDetailScreen({super.key, required this.downloadId});

  @override
  ConsumerState<DownloadDetailScreen> createState() => _DownloadDetailScreenState();
}

class _DownloadDetailScreenState extends ConsumerState<DownloadDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<LogEntry> _logEntries = [];
  final List<double> _speedHistory = List.filled(60, 0);
  double _averageSpeed = 0;
  StreamSubscription<DownloadEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _listenToEvents();
  }

  void _listenToEvents() {
    final manager = ref.read(downloadManagerProvider);
    _eventSubscription = manager.events
        .where((e) => e.downloadId == widget.downloadId)
        .listen(_handleEvent);
  }

  void _handleEvent(DownloadEvent event) {
    if (!mounted) return;

    switch (event.type) {
      case DownloadEventType.speed:
        setState(() {
          _speedHistory.removeAt(0);
          _speedHistory.add(event.data['bytesPerSecond'] as double);
          // Calculate average of non-zero entries
          final nonZero = _speedHistory.where((s) => s > 0);
          _averageSpeed = nonZero.isEmpty
              ? 0
              : nonZero.reduce((a, b) => a + b) / nonZero.length;
        });
        break;
      case DownloadEventType.log:
        setState(() {
          _logEntries.add(LogEntry(
            timestamp: event.timestamp,
            message: event.data['message'] as String,
          ));
        });
        break;
      default:
        // Other events trigger a rebuild via the provider
        setState(() {});
        break;
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final downloads = ref.watch(allDownloadsProvider);

    return downloads.when(
      data: (list) {
        final item = list.where((d) => d.id == widget.downloadId).firstOrNull;
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Download Not Found')),
            body: const Center(child: Text('This download no longer exists.')),
          );
        }
        return _buildDetail(context, theme, item);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildDetail(BuildContext context, ThemeData theme, DownloadItem item) {
    final manager = ref.read(downloadManagerProvider);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            StatusIcon(status: item.status, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                item.fileName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          if (item.status == 'paused' || item.status == 'error' || item.status == 'queued')
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Resume',
              onPressed: () => manager.resumeDownload(item.id!),
            ),
          if (item.isActive)
            IconButton(
              icon: const Icon(Icons.pause),
              tooltip: 'Pause',
              onPressed: () => manager.pauseDownload(item.id!),
            ),
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: 'Cancel',
            onPressed: () => manager.cancelDownload(item.id!),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Segments'),
            Tab(text: 'Speed'),
            Tab(text: 'Info'),
            Tab(text: 'Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Segments
          SegmentView(
            segments: item.segments,
            totalSize: item.totalSize,
          ),

          // Tab 2: Speed Graph
          SpeedGraph(
            speedHistory: _speedHistory,
            averageSpeed: _averageSpeed,
          ),

          // Tab 3: Info
          _buildInfoTab(theme, item, dateFormat),

          // Tab 4: Log
          LogView(entries: _logEntries),
        ],
      ),
    );
  }

  Widget _buildInfoTab(ThemeData theme, DownloadItem item, DateFormat dateFormat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoSection('File Information', [
            _infoRow('File Name', item.fileName),
            _infoRow('Size', SizeFormatter.format(item.totalSize)),
            _infoRow('Downloaded', SizeFormatter.format(item.downloadedSize)),
            _infoRow('Remaining', SizeFormatter.format(
              item.totalSize > 0 ? item.totalSize - item.downloadedSize : 0,
            )),
            _infoRow('Progress', '${(item.progress * 100).toStringAsFixed(1)}%'),
          ]),
          const SizedBox(height: 16),
          _infoSection('Transfer', [
            _infoRow('Status', item.status),
            _infoRow('Speed', SpeedFormatter.format(item.speed)),
            _infoRow('ETA', SpeedFormatter.formatEta(item.eta)),
            _infoRow('Threads', '${item.threadCount}'),
            _infoRow('Segments', '${item.segments.length}'),
          ]),
          const SizedBox(height: 16),
          _infoSection('Location', [
            _infoRow('URL', item.url),
            _infoRow('Save Path', item.savePath),
            _infoRow('Category', item.category ?? 'None'),
          ]),
          const SizedBox(height: 16),
          _infoSection('Dates', [
            _infoRow('Date Added', dateFormat.format(item.dateAdded)),
            if (item.dateCompleted != null)
              _infoRow('Date Completed', dateFormat.format(item.dateCompleted!)),
          ]),
          if (item.errorMessage != null) ...[
            const SizedBox(height: 16),
            _infoSection('Error', [
              _infoRow('Message', item.errorMessage!),
              _infoRow('Retries', '${item.retryCount}'),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _infoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            )),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
