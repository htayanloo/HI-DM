import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/file_utils.dart';
import '../../../core/utils/size_formatter.dart';
import '../../../core/utils/url_utils.dart';
import '../../../data/models/app_settings.dart';
import '../../../domain/services/segment_manager.dart';
import '../../providers/category_providers.dart';
import '../../providers/download_manager_provider.dart';
import '../../providers/queue_providers.dart';
import '../../providers/settings_providers.dart';

class AddUrlDialog extends ConsumerStatefulWidget {
  final String? initialUrl;

  const AddUrlDialog({super.key, this.initialUrl});

  @override
  ConsumerState<AddUrlDialog> createState() => _AddUrlDialogState();
}

class _AddUrlDialogState extends ConsumerState<AddUrlDialog> {
  final _urlController = TextEditingController();
  final _fileNameController = TextEditingController();
  final _savePathController = TextEditingController();
  final _refererController = TextEditingController();
  final _userAgentController = TextEditingController();
  final _headersController = TextEditingController();

  int _threadCount = AppConstants.defaultThreadCount;
  bool _startImmediately = true;
  bool _showAdvanced = false;
  bool _isAnalyzing = false;
  String? _selectedCategory;
  int? _selectedQueueId;
  int _fileSize = -1;
  bool _supportsRange = false;
  String? _errorMessage;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _userAgentController.text = AppConstants.defaultUserAgent;
    _loadDefaultSavePath();

    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      _analyzeUrl();
    } else {
      _pasteFromClipboard();
    }
  }

  Future<void> _loadDefaultSavePath() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final defaultPath = await settingsRepo.getValue(AppSettings.defaultSavePath);
    if (mounted && defaultPath.isNotEmpty && _savePathController.text.isEmpty) {
      setState(() {
        _savePathController.text = defaultPath;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _urlController.dispose();
    _fileNameController.dispose();
    _savePathController.dispose();
    _refererController.dispose();
    _userAgentController.dispose();
    _headersController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && UrlUtils.isValidUrl(data!.text!)) {
      _urlController.text = data.text!;
      _analyzeUrl();
    }
  }

  Future<void> _analyzeUrl() async {
    final url = _urlController.text.trim();
    if (!UrlUtils.isValidUrl(url)) {
      setState(() => _errorMessage = 'Invalid URL');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        followRedirects: true,
        maxRedirects: 20,
      ));
      final manager = SegmentManager(dio);
      final analysis = await manager.analyzeUrl(url);

      if (!mounted) return;

      // Use resolved URL to extract better filename
      final resolvedUrl = analysis.resolvedUrl ?? url;
      var fileName = analysis.suggestedFileName;
      fileName ??= FileUtils.getFileNameFromUrl(resolvedUrl);
      // If still no extension, try original URL (might have format= in query)
      if (!fileName.contains('.')) {
        fileName = FileUtils.getFileNameFromUrl(url);
      }

      setState(() {
        _fileSize = analysis.contentLength;
        _supportsRange = analysis.supportsRange;
        _isAnalyzing = false;
        _fileNameController.text = fileName!;
      });

      dio.close();

      // Auto-detect category and set its save path
      final categories = ref.read(allCategoriesProvider).valueOrNull ?? [];
      for (final cat in categories) {
        if (cat.matchesExtension(_fileNameController.text)) {
          setState(() {
            _selectedCategory = cat.name;
            // Only override save path with category path if it has one
            if (cat.defaultSavePath.isNotEmpty) {
              _savePathController.text = cat.defaultSavePath;
            }
          });
          break;
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _fileNameController.text = FileUtils.getFileNameFromUrl(url);
      });
    }
  }

  void _onUrlChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (UrlUtils.isValidUrl(value.trim())) {
        _analyzeUrl();
      }
    });
  }

  Future<void> _pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select save directory',
    );
    if (result != null) {
      setState(() {
        _savePathController.text = result;
      });
    }
  }

  Future<void> _addDownload() async {
    final url = _urlController.text.trim();
    if (!UrlUtils.isValidUrl(url)) {
      setState(() => _errorMessage = 'Please enter a valid URL');
      return;
    }

    if (_savePathController.text.isEmpty) {
      setState(() => _errorMessage = 'Please select a save directory');
      return;
    }

    // Build custom headers
    final headers = <String, String>{};
    if (_refererController.text.isNotEmpty) {
      headers['Referer'] = _refererController.text;
    }
    if (_userAgentController.text.isNotEmpty) {
      headers['User-Agent'] = _userAgentController.text;
    }
    for (final line in _headersController.text.split('\n')) {
      final idx = line.indexOf(':');
      if (idx > 0) {
        headers[line.substring(0, idx).trim()] = line.substring(idx + 1).trim();
      }
    }

    try {
      debugPrint('[AddDialog] Adding download: url=$url, savePath=${_savePathController.text}');
      final manager = ref.read(downloadManagerProvider);
      final id = await manager.addDownload(
        url: url,
        savePath: _savePathController.text,
        fileName: _fileNameController.text.isNotEmpty ? _fileNameController.text : null,
        threadCount: _threadCount,
        headers: headers,
        queueId: _selectedQueueId,
        startImmediately: _startImmediately,
      );
      debugPrint('[AddDialog] Download added with id=$id');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e, stack) {
      debugPrint('[AddDialog] ERROR: $e');
      debugPrint('[AddDialog] Stack: $stack');
      if (mounted) {
        setState(() => _errorMessage = 'Failed to add download: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? [];
    final queues = ref.watch(allQueuesProvider).valueOrNull ?? [];
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.download_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('New Download', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        Text('Add a file to download', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // URL field
                TextField(
                  controller: _urlController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Paste or enter download URL',
                    hintStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                    prefixIcon: Icon(Icons.link_rounded, size: 18, color: theme.colorScheme.primary),
                    suffixIcon: _isAnalyzing
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : IconButton(
                            icon: Icon(Icons.content_paste_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                            tooltip: 'Paste',
                            onPressed: _pasteFromClipboard,
                          ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                  ),
                  onChanged: _onUrlChanged,
                  maxLines: 1,
                ),
                const SizedBox(height: 12),

                // File info chips
                if (_fileSize > 0 || _supportsRange)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (_fileSize > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.storage_rounded, size: 14, color: theme.colorScheme.primary),
                                const SizedBox(width: 5),
                                Text(SizeFormatter.format(_fileSize), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                              ],
                            ),
                          ),
                        if (_supportsRange)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                                SizedBox(width: 5),
                                Text('Resumable', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                // Filename
                TextField(
                  controller: _fileNameController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'File name',
                    prefixIcon: Icon(Icons.insert_drive_file_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 12),

                // Save path
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _savePathController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Save location',
                          prefixIcon: Icon(Icons.folder_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                        ),
                        readOnly: true,
                        onTap: _pickDirectory,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      onPressed: _pickDirectory,
                      icon: const Icon(Icons.folder_open_rounded, size: 18),
                      label: const Text('Browse', style: TextStyle(fontSize: 12)),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category + Queue row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(fontSize: 13),
                          isDense: true,
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                        ),
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Auto-detect')),
                          ...categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                          if (value != null) {
                            final cat = categories.firstWhere((c) => c.name == value);
                            if (cat.defaultSavePath.isNotEmpty) {
                              _savePathController.text = cat.defaultSavePath;
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Queue selector
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _selectedQueueId,
                        decoration: InputDecoration(
                          labelText: 'Queue',
                          labelStyle: const TextStyle(fontSize: 13),
                          isDense: true,
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                        ),
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                        items: [
                          const DropdownMenuItem<int?>(value: null, child: Text('None')),
                          ...queues.map((q) => DropdownMenuItem<int?>(
                                value: q.id,
                                child: Text(q.name),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedQueueId = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Connections slider
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cable_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(width: 10),
                      Text('Connections', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      const Spacer(),
                      SizedBox(
                        width: 180,
                        child: SliderTheme(
                          data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
                          child: Slider(
                            value: _threadCount.toDouble(),
                            min: 1, max: 32, divisions: 31,
                            label: '$_threadCount',
                            onChanged: (v) => setState(() => _threadCount = v.round()),
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: Text(
                          '$_threadCount',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Start mode toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Switch(
                        value: _startImmediately,
                        onChanged: (v) => setState(() => _startImmediately = v),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _startImmediately ? 'Start immediately' : 'Add to queue (download later)',
                              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                            ),
                            if (!_startImmediately)
                              Text(
                                'Download will be queued and start when you resume it',
                                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Advanced section
                Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text('Advanced Options', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    initiallyExpanded: _showAdvanced,
                    onExpansionChanged: (v) => _showAdvanced = v,
                    children: [
                      TextField(controller: _refererController, style: const TextStyle(fontSize: 12), decoration: const InputDecoration(hintText: 'Referer URL', isDense: true)),
                      const SizedBox(height: 8),
                      TextField(controller: _userAgentController, style: const TextStyle(fontSize: 12), decoration: const InputDecoration(hintText: 'User-Agent', isDense: true)),
                      const SizedBox(height: 8),
                      TextField(controller: _headersController, style: const TextStyle(fontSize: 12), decoration: const InputDecoration(hintText: 'Custom headers (key: value per line)', isDense: true), maxLines: 3),
                    ],
                  ),
                ),

                // Error
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, size: 16, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error, fontSize: 12))),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _isAnalyzing ? null : _addDownload,
                      icon: Icon(_startImmediately ? Icons.download_rounded : Icons.queue_rounded, size: 18),
                      label: Text(_startImmediately ? 'Start Download' : 'Add to Queue'),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
