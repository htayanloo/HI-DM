import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/url_utils.dart';
import '../../providers/category_providers.dart';
import '../../providers/download_manager_provider.dart';

class BatchDownloadDialog extends ConsumerStatefulWidget {
  const BatchDownloadDialog({super.key});

  @override
  ConsumerState<BatchDownloadDialog> createState() => _BatchDownloadDialogState();
}

class _BatchDownloadDialogState extends ConsumerState<BatchDownloadDialog> {
  final _patternController = TextEditingController();
  final _savePathController = TextEditingController();
  List<String> _previewUrls = [];
  String? _selectedCategory;

  void _generatePreview() {
    final urls = UrlUtils.generateBatchUrls(_patternController.text.trim());
    setState(() => _previewUrls = urls);
  }

  Future<void> _pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select save directory',
    );
    if (result != null) {
      _savePathController.text = result;
    }
  }

  Future<void> _startBatchDownload() async {
    if (_previewUrls.isEmpty || _savePathController.text.isEmpty) return;

    final manager = ref.read(downloadManagerProvider);
    for (final url in _previewUrls) {
      await manager.addDownload(
        url: url,
        savePath: _savePathController.text,
        startImmediately: true,
      );
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _patternController.dispose();
    _savePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? [];
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
              Text('Batch Download', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Use [start-end] for numbered sequences.\nExample: https://example.com/photo_[001-100].jpg',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _patternController,
                decoration: InputDecoration(
                  labelText: 'URL Pattern',
                  hintText: 'https://example.com/file_[01-50].jpg',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.preview),
                    tooltip: 'Generate preview',
                    onPressed: _generatePreview,
                  ),
                ),
                onChanged: (_) => _generatePreview(),
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

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', isDense: true),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Auto')),
                  ...categories.map((c) => DropdownMenuItem(
                        value: c.name,
                        child: Text(c.name),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                  if (value != null) {
                    final cat = categories.firstWhere((c) => c.name == value);
                    _savePathController.text = cat.defaultSavePath;
                  }
                },
              ),
              const SizedBox(height: 12),

              Text('Preview (${_previewUrls.length} URLs):',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _previewUrls.length.clamp(0, 50),
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(
                        _previewUrls[i],
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              if (_previewUrls.length > 50)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '...and ${_previewUrls.length - 50} more',
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
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
                    onPressed: _previewUrls.isEmpty ? null : _startBatchDownload,
                    icon: const Icon(Icons.download, size: 18),
                    label: Text('Download ${_previewUrls.length} files'),
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
