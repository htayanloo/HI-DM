import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/url_utils.dart';
import '../../providers/download_manager_provider.dart';

class ImportListDialog extends ConsumerStatefulWidget {
  const ImportListDialog({super.key});

  @override
  ConsumerState<ImportListDialog> createState() => _ImportListDialogState();
}

class _ImportListDialogState extends ConsumerState<ImportListDialog> {
  final _savePathController = TextEditingController();
  List<String> _urls = [];
  final Set<int> _enabledIndices = {};

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      dialogTitle: 'Select URL list file',
    );

    if (result != null && result.files.single.path != null) {
      final content = await File(result.files.single.path!).readAsString();
      final urls = content
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && UrlUtils.isValidUrl(l))
          .toList();

      setState(() {
        _urls = urls;
        _enabledIndices.addAll(List.generate(urls.length, (i) => i));
      });
    }
  }

  Future<void> _pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select save directory',
    );
    if (result != null) {
      _savePathController.text = result;
    }
  }

  Future<void> _startDownloads() async {
    if (_savePathController.text.isEmpty) return;

    final manager = ref.read(downloadManagerProvider);
    for (final i in _enabledIndices) {
      await manager.addDownload(
        url: _urls[i],
        savePath: _savePathController.text,
        startImmediately: true,
      );
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _savePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 550),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Import URL List', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              FilledButton.tonalIcon(
                onPressed: _pickFile,
                icon: const Icon(Icons.file_open),
                label: const Text('Select .txt file'),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _savePathController,
                      decoration: const InputDecoration(labelText: 'Save to'),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: _pickDirectory,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Text('${_enabledIndices.length} / ${_urls.length} URLs selected',
                      style: const TextStyle(fontSize: 12)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _enabledIndices.addAll(
                        List.generate(_urls.length, (i) => i))),
                    child: const Text('Select All', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _enabledIndices.clear()),
                    child: const Text('Deselect All', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),

              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _urls.length,
                  itemBuilder: (_, i) => CheckboxListTile(
                    title: Text(
                      _urls[i],
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    value: _enabledIndices.contains(i),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _enabledIndices.add(i);
                        } else {
                          _enabledIndices.remove(i);
                        }
                      });
                    },
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _enabledIndices.isEmpty ? null : _startDownloads,
                    icon: const Icon(Icons.download, size: 18),
                    label: Text('Download ${_enabledIndices.length} files'),
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
