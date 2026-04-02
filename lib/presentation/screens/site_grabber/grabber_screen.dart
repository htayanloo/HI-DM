import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/services/site_grabber.dart';
import '../../providers/download_manager_provider.dart';

class GrabberScreen extends ConsumerStatefulWidget {
  const GrabberScreen({super.key});

  @override
  ConsumerState<GrabberScreen> createState() => _GrabberScreenState();
}

class _GrabberScreenState extends ConsumerState<GrabberScreen> {
  final _urlController = TextEditingController();
  final _savePathController = TextEditingController();
  int _maxDepth = 3;
  bool _sameHostOnly = true;
  bool _allowSubdomains = false;
  final Set<String> _typeFilters = {};

  SiteGrabber? _grabber;
  List<GrabbedLink> _results = [];
  bool _isRunning = false;
  int _pagesVisited = 0;
  int _linksFound = 0;

  final _typeOptions = ['image', 'video', 'audio', 'document', 'archive', 'other'];

  Future<void> _startCrawl() async {
    if (_urlController.text.trim().isEmpty) return;

    setState(() {
      _isRunning = true;
      _results = [];
      _pagesVisited = 0;
      _linksFound = 0;
    });

    _grabber = SiteGrabber();
    final results = await _grabber!.crawl(
      SiteGrabberConfig(
        startUrl: _urlController.text.trim(),
        maxDepth: _maxDepth,
        sameHostOnly: _sameHostOnly,
        allowSubdomains: _allowSubdomains,
        fileTypeFilters: _typeFilters,
      ),
      onProgress: (pages, links) {
        if (mounted) {
          setState(() {
            _pagesVisited = pages;
            _linksFound = links;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _results = results;
        _isRunning = false;
      });
    }
  }

  void _stopCrawl() {
    _grabber?.cancel();
    setState(() => _isRunning = false);
  }

  Future<void> _downloadSelected() async {
    final selected = _results.where((l) => l.selected).toList();
    if (selected.isEmpty || _savePathController.text.isEmpty) return;

    final manager = ref.read(downloadManagerProvider);
    for (final link in selected) {
      await manager.addDownload(
        url: link.url,
        savePath: _savePathController.text,
        startImmediately: true,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${selected.length} downloads')),
      );
    }
  }

  @override
  void dispose() {
    _grabber?.dispose();
    _urlController.dispose();
    _savePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = _results.where((l) => l.selected).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Site Grabber')),
      body: Column(
        children: [
          // Config section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Website URL',
                    hintText: 'https://example.com',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _savePathController,
                  decoration: const InputDecoration(labelText: 'Save to'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Depth: $_maxDepth'),
                    Expanded(
                      child: Slider(
                        value: _maxDepth.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (v) => setState(() => _maxDepth = v.round()),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _sameHostOnly,
                      onChanged: (v) => setState(() => _sameHostOnly = v ?? true),
                    ),
                    const Text('Same host only', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 16),
                    Checkbox(
                      value: _allowSubdomains,
                      onChanged: _sameHostOnly ? (v) => setState(() => _allowSubdomains = v ?? false) : null,
                    ),
                    const Text('Allow subdomains', style: TextStyle(fontSize: 13)),
                  ],
                ),
                Wrap(
                  spacing: 4,
                  children: _typeOptions.map((type) => FilterChip(
                    label: Text(type, style: const TextStyle(fontSize: 11)),
                    selected: _typeFilters.contains(type),
                    onSelected: (sel) {
                      setState(() {
                        if (sel) {
                          _typeFilters.add(type);
                        } else {
                          _typeFilters.remove(type);
                        }
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _isRunning ? null : _startCrawl,
                      icon: const Icon(Icons.explore, size: 18),
                      label: const Text('Explore'),
                    ),
                    if (_isRunning) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _stopCrawl,
                        icon: const Icon(Icons.stop, size: 18),
                        label: const Text('Stop'),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Text('Pages: $_pagesVisited, Links: $_linksFound', style: const TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Results
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('$selectedCount / ${_results.length} selected', style: const TextStyle(fontSize: 12)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    for (final l in _results) { l.selected = true; }
                  }),
                  child: const Text('Select All', style: TextStyle(fontSize: 12)),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    for (final l in _results) { l.selected = false; }
                  }),
                  child: const Text('Deselect All', style: TextStyle(fontSize: 12)),
                ),
                FilledButton.icon(
                  onPressed: selectedCount > 0 ? _downloadSelected : null,
                  icon: const Icon(Icons.download, size: 18),
                  label: Text('Download ($selectedCount)'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final link = _results[i];
                return CheckboxListTile(
                  value: link.selected,
                  onChanged: (v) => setState(() => link.selected = v ?? false),
                  title: Text(link.url, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${link.type} (depth: ${link.depth})', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                  secondary: Icon(_getTypeIcon(link.type), size: 18),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    return switch (type) {
      'image' => Icons.image,
      'video' => Icons.movie,
      'audio' => Icons.music_note,
      'document' => Icons.description,
      'archive' => Icons.folder_zip,
      _ => Icons.insert_drive_file,
    };
  }
}
