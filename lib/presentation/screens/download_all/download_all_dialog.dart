import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/download_manager_provider.dart';

/// Dialog for downloading all links from a page.
/// Used by the Site Grabber and browser integration features.
class DownloadAllDialog extends ConsumerStatefulWidget {
  final List<String> urls;
  final String? defaultSavePath;

  const DownloadAllDialog({
    super.key,
    required this.urls,
    this.defaultSavePath,
  });

  @override
  ConsumerState<DownloadAllDialog> createState() => _DownloadAllDialogState();
}

class _DownloadAllDialogState extends ConsumerState<DownloadAllDialog> {
  late final Set<int> _selectedIndices;
  String _filterText = '';

  @override
  void initState() {
    super.initState();
    _selectedIndices = Set.from(List.generate(widget.urls.length, (i) => i));
  }

  List<MapEntry<int, String>> get _filteredUrls {
    if (_filterText.isEmpty) {
      return widget.urls.asMap().entries.toList();
    }
    return widget.urls.asMap().entries
        .where((e) => e.value.toLowerCase().contains(_filterText.toLowerCase()))
        .toList();
  }

  Future<void> _downloadSelected() async {
    if (widget.defaultSavePath == null || widget.defaultSavePath!.isEmpty) return;

    final manager = ref.read(downloadManagerProvider);
    for (final i in _selectedIndices) {
      await manager.addDownload(
        url: widget.urls[i],
        savePath: widget.defaultSavePath!,
        startImmediately: true,
      );
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredUrls;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Download All Links', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),

              // Filter
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Filter URLs...',
                  prefixIcon: Icon(Icons.filter_list, size: 18),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _filterText = v),
              ),
              const SizedBox(height: 8),

              // Select controls
              Row(
                children: [
                  Text('${_selectedIndices.length} / ${widget.urls.length} selected',
                      style: const TextStyle(fontSize: 12)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() =>
                        _selectedIndices.addAll(List.generate(widget.urls.length, (i) => i))),
                    child: const Text('All', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedIndices.clear()),
                    child: const Text('None', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),

              // URL list
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final entry = filtered[i];
                    return CheckboxListTile(
                      value: _selectedIndices.contains(entry.key),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selectedIndices.add(entry.key);
                          } else {
                            _selectedIndices.remove(entry.key);
                          }
                        });
                      },
                      title: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _selectedIndices.isEmpty ? null : _downloadSelected,
                    icon: const Icon(Icons.download, size: 18),
                    label: Text('Download (${_selectedIndices.length})'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
