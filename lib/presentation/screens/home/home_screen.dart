import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/speed_formatter.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/download_item.dart';
import '../../../domain/services/clipboard_monitor.dart';
import '../../../platform/desktop/system_tray.dart';
import '../../../platform/desktop/window_config.dart';
import '../../providers/category_providers.dart';
import '../../providers/download_manager_provider.dart';
import '../../providers/download_providers.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/custom_title_bar.dart';
import '../../widgets/download_settings_dialog.dart';
import '../../widgets/download_tile.dart';
import '../add_download/add_url_dialog.dart';
import '../add_download/batch_download_dialog.dart';
import '../add_download/import_list_dialog.dart';
import '../download_detail/detail_screen.dart';
import '../scheduler/scheduler_screen.dart';
import '../settings/settings_screen.dart';
import '../site_grabber/grabber_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _sidebarExpanded = true;
  ClipboardMonitor? _clipboardMonitor;
  bool _clipboardDialogShowing = false;
  final _tray = SystemTrayService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(downloadManagerProvider).initialize();
      _initClipboardMonitor();
      _initSystemTray();
    });
  }

  @override
  void dispose() {
    _clipboardMonitor?.dispose();
    _tray.dispose();
    super.dispose();
  }

  void _initSystemTray() {
    _tray.onShowWindow = () {
      // Window will be shown by tray service
    };
    _tray.onAddUrl = () => _showAddUrlDialog();
    _tray.onPauseAll = () => ref.read(downloadManagerProvider).pauseAll();
    _tray.onResumeAll = () => ref.read(downloadManagerProvider).resumeAll();
    _tray.onQuit = () => WindowConfig.close();
    _tray.initialize();
  }

  Future<void> _initClipboardMonitor() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final enabled = await settingsRepo.getBoolValue(AppSettings.clipboardMonitoring);
    if (!enabled) return;

    _clipboardMonitor = ClipboardMonitor(
      onUrlDetected: (url) {
        if (!mounted || _clipboardDialogShowing) return;
        _clipboardDialogShowing = true;
        _showClipboardDialog(url);
      },
    );
    _clipboardMonitor!.start();
  }

  void _showClipboardDialog(String url) {
    showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.content_paste_go_rounded, size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              const Text('Download Link Detected'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('A download link was found in your clipboard:', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  url,
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: theme.colorScheme.primary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Ignore'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download'),
            ),
          ],
        );
      },
    ).then((result) {
      _clipboardDialogShowing = false;
      if (result == true) {
        _showAddUrlDialog(url);
      }
    });
  }

  void _showAddUrlDialog([String? url]) {
    showDialog<bool>(context: context, builder: (_) => AddUrlDialog(initialUrl: url));
  }

  Future<void> _openFolder(String path) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', [path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      }
    } catch (_) {}
  }

  void _showBatchDialog() {
    showDialog<bool>(context: context, builder: (_) => const BatchDownloadDialog());
  }

  void _showImportDialog() {
    showDialog<bool>(context: context, builder: (_) => const ImportListDialog());
  }

  Future<void> _resumeSelected() async {
    final manager = ref.read(downloadManagerProvider);
    final ids = ref.read(selectedDownloadIdsProvider);
    if (ids.isNotEmpty) {
      for (final id in ids) {
        await manager.resumeDownload(id);
      }
    } else {
      // No selection -> resume all paused
      await manager.resumeAll();
    }
  }

  Future<void> _pauseSelected() async {
    final manager = ref.read(downloadManagerProvider);
    final ids = ref.read(selectedDownloadIdsProvider);
    if (ids.isNotEmpty) {
      for (final id in ids) {
        await manager.pauseDownload(id);
      }
    } else {
      // No selection -> pause all active
      await manager.pauseAll();
    }
  }

  Future<void> _cancelSelected() async {
    final manager = ref.read(downloadManagerProvider);
    final ids = ref.read(selectedDownloadIdsProvider);
    if (ids.isNotEmpty) {
      for (final id in ids) {
        await manager.cancelDownload(id);
      }
    } else {
      await manager.pauseAll();
    }
  }

  Future<void> _deleteSelected() async {
    final ids = ref.read(selectedDownloadIdsProvider);
    if (ids.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Downloads'),
        content: Text('Delete ${ids.length} download(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
          FilledButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Delete + Remove Files')),
        ],
      ),
    );
    if (confirmed == null || confirmed == true) {
      final manager = ref.read(downloadManagerProvider);
      for (final id in ids) {
        await manager.deleteDownload(id, deleteFile: confirmed == null);
      }
      ref.read(selectedDownloadIdsProvider.notifier).state = {};
    }
  }

  void _showContextMenu(BuildContext context, Offset position, DownloadItem item) {
    final manager = ref.read(downloadManagerProvider);
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(position & const Size(1, 1), Offset.zero & overlay.size),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        if (item.status == 'paused' || item.status == 'error' || item.status == 'queued')
          const PopupMenuItem(value: 'resume', child: _ContextMenuItem(icon: Icons.play_arrow_rounded, label: 'Resume')),
        if (item.isActive)
          const PopupMenuItem(value: 'pause', child: _ContextMenuItem(icon: Icons.pause_rounded, label: 'Pause')),
        const PopupMenuItem(value: 'delete', child: _ContextMenuItem(icon: Icons.delete_outline_rounded, label: 'Delete')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'settings', child: _ContextMenuItem(icon: Icons.tune_rounded, label: 'Speed / Connections')),
        const PopupMenuItem(value: 'copyUrl', child: _ContextMenuItem(icon: Icons.copy_rounded, label: 'Copy URL')),
        const PopupMenuItem(value: 'openFolder', child: _ContextMenuItem(icon: Icons.folder_open_rounded, label: 'Open Folder')),
      ],
    ).then((value) {
      if (value == null || item.id == null) return;
      switch (value) {
        case 'resume': manager.resumeDownload(item.id!);
        case 'pause': manager.pauseDownload(item.id!);
        case 'delete': manager.deleteDownload(item.id!);
        case 'settings':
          if (context.mounted) {
            showDialog(context: context, builder: (_) => DownloadSettingsDialog(item: item));
          }
        case 'copyUrl':
          Clipboard.setData(ClipboardData(text: item.url));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('URL copied to clipboard'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        case 'openFolder':
          _openFolder(item.savePath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final downloads = ref.watch(filteredDownloadsProvider);
    final categories = ref.watch(allCategoriesProvider);
    final activeCount = ref.watch(activeDownloadsCountProvider);
    final totalSpeed = ref.watch(totalSpeedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Custom titlebar
          const CustomTitleBar(),
          // Modern toolbar
          _buildToolbar(context, theme),
          // Main content
          Expanded(
            child: Row(
              children: [
                // Sidebar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  width: _sidebarExpanded ? 220 : 0,
                  child: _sidebarExpanded
                      ? _buildSidebar(context, theme, categories)
                      : const SizedBox.shrink(),
                ),
                // Download list
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: _sidebarExpanded
                          ? const BorderRadius.only(topLeft: Radius.circular(20))
                          : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildDownloadList(context, theme, downloads),
                  ),
                ),
              ],
            ),
          ),
          // Status bar
          _buildStatusBar(context, theme, activeCount, totalSpeed),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          // Add button — click shows menu with all options
          PopupMenuButton<String>(
            tooltip: 'Add Download',
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              switch (value) {
                case 'url': _showAddUrlDialog();
                case 'batch': _showBatchDialog();
                case 'import': _showImportDialog();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'url', child: _ContextMenuItem(icon: Icons.add_link_rounded, label: 'Add URL')),
              PopupMenuItem(value: 'batch', child: _ContextMenuItem(icon: Icons.format_list_numbered_rounded, label: 'Batch Download')),
              PopupMenuItem(value: 'import', child: _ContextMenuItem(icon: Icons.file_upload_rounded, label: 'Import from File')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 6),
                  Text('Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimary)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded, size: 18, color: theme.colorScheme.onPrimary),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Action buttons
          _ToolbarIconButton(icon: Icons.play_arrow_rounded, tooltip: 'Resume', onPressed: _resumeSelected),
          _ToolbarIconButton(icon: Icons.pause_rounded, tooltip: 'Pause', onPressed: _pauseSelected),
          _ToolbarIconButton(icon: Icons.stop_rounded, tooltip: 'Stop', onPressed: _cancelSelected),
          _ToolbarIconButton(icon: Icons.delete_outline_rounded, tooltip: 'Delete', onPressed: _deleteSelected),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: theme.dividerColor.withValues(alpha: 0.3)),
          const SizedBox(width: 8),
          _ToolbarIconButton(
            icon: Icons.schedule_rounded,
            tooltip: 'Scheduler',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SchedulerScreen())),
          ),
          _ToolbarIconButton(
            icon: Icons.language_rounded,
            tooltip: 'Site Grabber',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GrabberScreen())),
          ),
          const Spacer(),
          // Search field
          SizedBox(
            width: 220,
            height: 38,
            child: TextField(
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search downloads...',
                hintStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
            ),
          ),
          const SizedBox(width: 8),
          _ToolbarIconButton(
            icon: _sidebarExpanded ? Icons.view_sidebar_rounded : Icons.menu_rounded,
            tooltip: 'Toggle Sidebar',
            onPressed: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
          ),
          _ToolbarIconButton(
            icon: Icons.settings_rounded,
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, ThemeData theme, AsyncValue categories) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedStatus = ref.watch(selectedStatusFilterProvider);

    // Compute counts
    final allDownloads = ref.watch(allDownloadsProvider).valueOrNull ?? [];
    int countByStatus(String s) => allDownloads.where((d) => d.status == s).length;
    int countByCategory(String c) => allDownloads.where((d) => d.category == c).length;

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Text(
              'LIBRARY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              children: [
                _SidebarItem(
                  icon: Icons.download_rounded,
                  label: 'All Downloads',
                  count: allDownloads.length,
                  isSelected: selectedCategory == null && selectedStatus == null,
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = null;
                    ref.read(selectedStatusFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(height: 4),
                _SidebarItem(
                  icon: Icons.downloading_rounded,
                  label: 'Downloading',
                  count: countByStatus('downloading') + countByStatus('connecting'),
                  isSelected: selectedStatus == 'downloading',
                  accentColor: const Color(0xFF6366F1),
                  onTap: () {
                    ref.read(selectedStatusFilterProvider.notifier).state = 'downloading';
                    ref.read(selectedCategoryProvider.notifier).state = null;
                  },
                ),
                _SidebarItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed',
                  count: countByStatus('completed'),
                  isSelected: selectedStatus == 'completed',
                  accentColor: const Color(0xFF10B981),
                  onTap: () {
                    ref.read(selectedStatusFilterProvider.notifier).state = 'completed';
                    ref.read(selectedCategoryProvider.notifier).state = null;
                  },
                ),
                _SidebarItem(
                  icon: Icons.schedule_rounded,
                  label: 'Queued',
                  count: countByStatus('queued'),
                  isSelected: selectedStatus == 'queued',
                  onTap: () {
                    ref.read(selectedStatusFilterProvider.notifier).state = 'queued';
                    ref.read(selectedCategoryProvider.notifier).state = null;
                  },
                ),
                _SidebarItem(
                  icon: Icons.pause_circle_rounded,
                  label: 'Paused',
                  count: countByStatus('paused'),
                  isSelected: selectedStatus == 'paused',
                  accentColor: const Color(0xFFF59E0B),
                  onTap: () {
                    ref.read(selectedStatusFilterProvider.notifier).state = 'paused';
                    ref.read(selectedCategoryProvider.notifier).state = null;
                  },
                ),
                _SidebarItem(
                  icon: Icons.error_rounded,
                  label: 'Errors',
                  count: countByStatus('error'),
                  isSelected: selectedStatus == 'error',
                  accentColor: const Color(0xFFEF4444),
                  onTap: () {
                    ref.read(selectedStatusFilterProvider.notifier).state = 'error';
                    ref.read(selectedCategoryProvider.notifier).state = null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                  child: Text(
                    'CATEGORIES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                categories.when(
                  data: (cats) => Column(
                    children: [
                      for (final cat in cats)
                        _SidebarItem(
                          icon: _getCategoryIcon(cat.icon),
                          label: cat.name,
                          count: countByCategory(cat.name),
                          isSelected: selectedCategory == cat.name,
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).state = cat.name;
                            ref.read(selectedStatusFilterProvider.notifier).state = null;
                          },
                        ),
                    ],
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadList(BuildContext context, ThemeData theme, AsyncValue<List<DownloadItem>> downloads) {
    return downloads.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                        theme.colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    size: 36,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No downloads yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add a URL to start downloading',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _showAddUrlDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Download'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        final selectedIds = ref.watch(selectedDownloadIdsProvider);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return DownloadTile(
              item: item,
              isSelected: item.id != null && selectedIds.contains(item.id),
              onTap: () {
                if (item.id == null) return;
                final ids = Set<int>.from(selectedIds);
                if (ids.contains(item.id)) { ids.remove(item.id); } else { ids.add(item.id!); }
                ref.read(selectedDownloadIdsProvider.notifier).state = ids;
              },
              onDoubleTap: () {
                if (item.id != null) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => DownloadDetailScreen(downloadId: item.id!)));
                }
              },
              onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition, item),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildStatusBar(BuildContext context, ThemeData theme, int activeCount, double totalSpeed) {
    // Update system tray with current stats
    _tray.updateStats(totalSpeed: totalSpeed, activeDownloads: activeCount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          // Active indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeCount > 0 ? const Color(0xFF10B981) : theme.colorScheme.outlineVariant,
              boxShadow: activeCount > 0
                  ? [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.4), blurRadius: 6)]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$activeCount active',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 20),
          Icon(Icons.speed_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          Text(
            SpeedFormatter.format(totalSpeed),
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            'HI-DM',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    return switch (iconName) {
      'description' => Icons.description_rounded,
      'folder_zip' => Icons.folder_zip_rounded,
      'music_note' => Icons.music_note_rounded,
      'movie' => Icons.movie_rounded,
      'apps' => Icons.apps_rounded,
      'image' => Icons.image_rounded,
      _ => Icons.folder_rounded,
    };
  }
}

// --- Reusable Widgets ---

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isSelected;
  final Color? accentColor;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.count = 0,
    required this.isSelected,
    this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = isSelected
        ? (accentColor ?? theme.colorScheme.primary)
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: isSelected
            ? (accentColor ?? theme.colorScheme.primary).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(icon, size: 18, color: effectiveColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? effectiveColor : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: (accentColor ?? theme.colorScheme.primary).withValues(alpha: isSelected ? 0.2 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? effectiveColor : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContextMenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
