import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/download_category.dart';
import '../../../data/models/proxy_config.dart';
import '../../providers/category_providers.dart';
import '../../providers/download_manager_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/settings_providers.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_title_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _section = 0;

  static const _sections = [
    (icon: Icons.tune_rounded, label: 'General'),
    (icon: Icons.wifi_rounded, label: 'Connection'),
    (icon: Icons.download_rounded, label: 'Downloads'),
    (icon: Icons.palette_rounded, label: 'Appearance'),
    (icon: Icons.folder_rounded, label: 'Categories'),
    (icon: Icons.rocket_launch_rounded, label: 'Advanced'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          const CustomTitleBar(),
          Expanded(
            child: Row(
              children: [
                // Sidebar — mirrors the main screen's navigation style
                Container(
                  width: 220,
                  color: theme.colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back_rounded,
                                size: 18, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => Navigator.of(context).maybePop(),
                              borderRadius: BorderRadius.circular(8),
                              child: const Text(
                                'BACK',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 16, 8),
                        child: Text(
                          'SETTINGS',
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
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          children: [
                            for (var i = 0; i < _sections.length; i++)
                              _Navitem(
                                icon: _sections[i].icon,
                                label: _sections[i].label,
                                isSelected: _section == i,
                                onTap: () => setState(() => _section = i),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content — rounded card area like the main list
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildSection(theme),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme) {
    return switch (_section) {
      0 => const _GeneralTab(),
      1 => const _ConnectionTab(),
      2 => const _DownloadsTab(),
      3 => const _AppearanceTab(),
      4 => const _CategoriesTab(),
      _ => const _AdvancedTab(),
    };
  }
}

class _Navitem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Navitem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
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

/// Card container that groups related settings — matches the main screen's
/// rounded, card-based visual style.
class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? accent;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = accent ?? theme.colorScheme.primary;

    // Material (not a plain Container) so ListTiles paint their own
    // background and ink splashes correctly on top of the card surface.
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 15, color: cardColor),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 8, indent: 16, endIndent: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _GeneralTab extends ConsumerWidget {
  const _GeneralTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(allSettingsProvider);

    return settings.when(
      data: (map) => _SettingsList(children: [
        SettingsCard(
          title: 'Startup & Background',
          icon: Icons.rocket_launch_rounded,
          children: [
            SwitchListTile(
              title: const Text('Start with OS'),
              subtitle: const Text('Launch HI-DM when the system starts'),
              value: map[AppSettings.startWithOs] == 'true',
              onChanged: (v) {
                ref.read(settingsRepositoryProvider).setBoolValue(AppSettings.startWithOs, v);
                ref.invalidate(allSettingsProvider);
              },
            ),
            SwitchListTile(
              title: const Text('Start minimized'),
              value: map[AppSettings.startMinimized] == 'true',
              onChanged: (v) {
                ref.read(settingsRepositoryProvider).setBoolValue(AppSettings.startMinimized, v);
                ref.invalidate(allSettingsProvider);
              },
            ),
            SwitchListTile(
              title: const Text('Minimize to tray'),
              subtitle: const Text('Hide the window but keep downloads running'),
              value: map[AppSettings.minimizeToTray] == 'true',
              onChanged: (v) {
                ref.read(settingsRepositoryProvider).setBoolValue(AppSettings.minimizeToTray, v);
                ref.invalidate(allSettingsProvider);
              },
            ),
          ],
        ),
        SettingsCard(
          title: 'Behavior',
          icon: Icons.mouse_rounded,
          accent: const Color(0xFF8B5CF6),
          children: [
            SwitchListTile(
              title: const Text('Clipboard monitoring'),
              subtitle: const Text('Auto-detect copied URLs'),
              value: map[AppSettings.clipboardMonitoring] == 'true',
              onChanged: (v) {
                ref.read(settingsRepositoryProvider).setBoolValue(AppSettings.clipboardMonitoring, v);
                ref.invalidate(allSettingsProvider);
              },
            ),
            SwitchListTile(
              title: const Text('Confirm on delete'),
              value: map[AppSettings.confirmOnDelete] == 'true',
              onChanged: (v) {
                ref.read(settingsRepositoryProvider).setBoolValue(AppSettings.confirmOnDelete, v);
                ref.invalidate(allSettingsProvider);
              },
            ),
          ],
        ),
        SettingsCard(
          title: 'Performance',
          icon: Icons.speed_rounded,
          accent: const Color(0xFF10B981),
          children: [
            ListTile(
              title: const Text('Default thread count'),
              subtitle: Text('${map[AppSettings.defaultThreadCount] ?? "8"} connections'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: double.tryParse(map[AppSettings.defaultThreadCount] ?? '8') ?? 8,
                  min: 1,
                  max: 32,
                  divisions: 31,
                  label: map[AppSettings.defaultThreadCount] ?? '8',
                  onChanged: (v) {
                    ref.read(settingsRepositoryProvider).setIntValue(AppSettings.defaultThreadCount, v.round());
                    ref.invalidate(allSettingsProvider);
                  },
                ),
              ),
            ),
            ListTile(
              title: const Text('Max concurrent downloads'),
              subtitle: Text('${map[AppSettings.maxConcurrentDownloads] ?? "3"} downloads'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: double.tryParse(map[AppSettings.maxConcurrentDownloads] ?? '3') ?? 3,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: map[AppSettings.maxConcurrentDownloads] ?? '3',
                  onChanged: (v) {
                    ref.read(settingsRepositoryProvider).setIntValue(AppSettings.maxConcurrentDownloads, v.round());
                    ref.invalidate(allSettingsProvider);
                  },
                ),
              ),
            ),
            ListTile(
              title: const Text('Queue order'),
              subtitle: const Text('Order in which queued downloads start'),
              trailing: DropdownButton<String>(
                value: map[AppSettings.queueOrder] ?? 'fifo',
                items: const [
                  DropdownMenuItem(value: 'fifo', child: Text('Oldest first')),
                  DropdownMenuItem(value: 'lifo', child: Text('Newest first')),
                  DropdownMenuItem(value: 'largest', child: Text('Largest file first')),
                  DropdownMenuItem(value: 'smallest', child: Text('Smallest file first')),
                  DropdownMenuItem(value: 'name', child: Text('Name (A–Z)')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  ref.read(settingsRepositoryProvider).setValue(AppSettings.queueOrder, v);
                  ref.read(downloadManagerProvider).setQueueOrder(v);
                  ref.invalidate(allSettingsProvider);
                },
              ),
            ),
          ],
        ),
      ]),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ConnectionTab extends ConsumerWidget {
  const _ConnectionTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(allSettingsProvider);

    return settings.when(
      data: (map) => _SettingsList(children: [
        SettingsCard(
          title: 'Time & Retries',
          icon: Icons.timer_rounded,
          children: [
            ListTile(
              title: const Text('Connection timeout'),
              subtitle: Text('${map[AppSettings.connectionTimeout] ?? "30"} seconds'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: double.tryParse(map[AppSettings.connectionTimeout] ?? '30') ?? 30,
                  min: 5,
                  max: 120,
                  divisions: 23,
                  onChanged: (v) {
                    ref.read(settingsRepositoryProvider).setIntValue(AppSettings.connectionTimeout, v.round());
                    ref.invalidate(allSettingsProvider);
                  },
                ),
              ),
            ),
            ListTile(
              title: const Text('Retry count'),
              subtitle: Text('${map[AppSettings.retryCount] ?? "5"} retries'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: double.tryParse(map[AppSettings.retryCount] ?? '5') ?? 5,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  onChanged: (v) {
                    ref.read(settingsRepositoryProvider).setIntValue(AppSettings.retryCount, v.round());
                    ref.invalidate(allSettingsProvider);
                  },
                ),
              ),
            ),
            ListTile(
              title: const Text('Retry delay'),
              subtitle: Text('${map[AppSettings.retryDelay] ?? "5"} seconds'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: double.tryParse(map[AppSettings.retryDelay] ?? '5') ?? 5,
                  min: 1,
                  max: 60,
                  divisions: 59,
                  onChanged: (v) {
                    ref.read(settingsRepositoryProvider).setIntValue(AppSettings.retryDelay, v.round());
                    ref.invalidate(allSettingsProvider);
                  },
                ),
              ),
            ),
          ],
        ),
        _GlobalProxySection(map: map),
      ]),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _GlobalProxySection extends ConsumerWidget {
  final Map<String, String> map;
  const _GlobalProxySection({required this.map});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = map[AppSettings.globalProxyEnabled] == 'true';
    final configStr = map[AppSettings.globalProxyConfig] ?? '';
    ProxyConfig? current;
    try {
      if (configStr.isNotEmpty) current = ProxyConfig.decode(configStr);
    } catch (_) {}

    return SettingsCard(
      title: 'Proxy',
      icon: Icons.dns_rounded,
      accent: const Color(0xFFF59E0B),
      children: [
        SwitchListTile(
          title: const Text('Global Proxy'),
          subtitle: Text(
            enabled && current != null && current.type != 'none'
                ? '${current.type.toUpperCase()}://${current.host}:${current.port}'
                : 'No proxy configured',
          ),
          value: enabled,
          onChanged: (v) {
            ref.read(settingsRepositoryProvider).setBoolValue(AppSettings.globalProxyEnabled, v);
            ref.invalidate(allSettingsProvider);
          },
        ),
        if (enabled)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Configure Proxy'),
              onPressed: () => _showProxyEditor(context, ref, current),
            ),
          ),
      ],
    );
  }

  void _showProxyEditor(BuildContext context, WidgetRef ref, ProxyConfig? current) {
    showDialog(
      context: context,
      builder: (ctx) => ProxyConfigDialog(
        initial: current,
        onSave: (config) {
          ref.read(settingsRepositoryProvider).setValue(
            AppSettings.globalProxyConfig,
            config.encode(),
          );
          ref.read(settingsRepositoryProvider).setBoolValue(
            AppSettings.globalProxyEnabled,
            config.type != 'none',
          );
          ref.invalidate(allSettingsProvider);
        },
      ),
    );
  }
}

/// Reusable proxy configuration dialog — used in both global settings and per-download settings.
class ProxyConfigDialog extends StatefulWidget {
  final ProxyConfig? initial;
  final ValueChanged<ProxyConfig> onSave;

  const ProxyConfigDialog({super.key, this.initial, required this.onSave});

  @override
  State<ProxyConfigDialog> createState() => _ProxyConfigDialogState();
}

class _ProxyConfigDialogState extends State<ProxyConfigDialog> {
  late String _type;
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _type = widget.initial?.type ?? 'http';
    _hostController = TextEditingController(text: widget.initial?.host ?? '');
    _portController = TextEditingController(
      text: widget.initial != null && widget.initial!.port > 0
          ? widget.initial!.port.toString()
          : '',
    );
    _usernameController = TextEditingController(text: widget.initial?.username ?? '');
    _passwordController = TextEditingController(text: widget.initial?.password ?? '');
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Proxy Configuration'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Proxy Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'http', child: Text('HTTP')),
                DropdownMenuItem(value: 'https', child: Text('HTTPS')),
                DropdownMenuItem(value: 'socks4', child: Text('SOCKS4')),
                DropdownMenuItem(value: 'socks5', child: Text('SOCKS5')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'http'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host',
                hintText: '127.0.0.1 or proxy.example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: 'Port',
                hintText: _type.startsWith('socks') ? '1080' : '8080',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password (optional)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Clear / disable proxy
            widget.onSave(ProxyConfig.none());
            Navigator.pop(context);
          },
          child: const Text('Remove Proxy'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final host = _hostController.text.trim();
            final port = int.tryParse(_portController.text.trim()) ?? 0;
            if (host.isEmpty || port <= 0) return;
            widget.onSave(ProxyConfig(
              type: _type,
              host: host,
              port: port,
              username: _usernameController.text.trim().isNotEmpty
                  ? _usernameController.text.trim()
                  : null,
              password: _passwordController.text.trim().isNotEmpty
                  ? _passwordController.text.trim()
                  : null,
            ));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DownloadsTab extends ConsumerWidget {
  const _DownloadsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(allSettingsProvider);

    return settings.when(
      data: (map) => _SettingsList(children: [
        SettingsCard(
          title: 'Save Locations',
          icon: Icons.folder_rounded,
          children: [
            ListTile(
              title: const Text('Default save path'),
              subtitle: Text(
                map[AppSettings.defaultSavePath]?.isNotEmpty == true
                    ? map[AppSettings.defaultSavePath]!
                    : 'Not set',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: () async {
                  final path = await FilePicker.platform.getDirectoryPath();
                  if (path != null) {
                    // Mark as user-customized so startup never resets it.
                    final repo = ref.read(settingsRepositoryProvider);
                    await repo.setValue(AppSettings.defaultSavePath, path);
                    await repo.setBoolValue(AppSettings.savePathCustomized, true);
                    ref.invalidate(allSettingsProvider);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Temp files directory'),
              subtitle: Text(map[AppSettings.tempDirectory]?.isNotEmpty == true
                  ? map[AppSettings.tempDirectory]!
                  : 'System default'),
              trailing: IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: () async {
                  final path = await FilePicker.platform.getDirectoryPath();
                  if (path != null) {
                    ref.read(settingsRepositoryProvider).setValue(AppSettings.tempDirectory, path);
                    ref.invalidate(allSettingsProvider);
                  }
                },
              ),
            ),
          ],
        ),
        SettingsCard(
          title: 'Organization',
          icon: Icons.category_rounded,
          accent: const Color(0xFF8B5CF6),
          children: [
            SwitchListTile(
              title: const Text('Auto-categorize downloads'),
              value: map[AppSettings.autoCategories] == 'true',
              onChanged: (v) {
                ref.read(settingsRepositoryProvider).setBoolValue(AppSettings.autoCategories, v);
                ref.invalidate(allSettingsProvider);
              },
            ),
            ListTile(
              title: const Text('Duplicate handling'),
              trailing: DropdownButton<String>(
                value: map[AppSettings.duplicateHandling] ?? 'ask',
                items: const [
                  DropdownMenuItem(value: 'ask', child: Text('Ask')),
                  DropdownMenuItem(value: 'rename', child: Text('Rename')),
                  DropdownMenuItem(value: 'overwrite', child: Text('Overwrite')),
                  DropdownMenuItem(value: 'skip', child: Text('Skip')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(settingsRepositoryProvider).setValue(AppSettings.duplicateHandling, v);
                    ref.invalidate(allSettingsProvider);
                  }
                },
              ),
            ),
          ],
        ),
        const _TempCleanupCard(),
      ]),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

/// Lets the user reclaim disk space from half-downloaded leftovers.
class _TempCleanupCard extends ConsumerStatefulWidget {
  const _TempCleanupCard();

  @override
  ConsumerState<_TempCleanupCard> createState() => _TempCleanupCardState();
}

class _TempCleanupCardState extends ConsumerState<_TempCleanupCard> {
  bool _busy = false;

  Future<void> _run(String label, Future<int> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final removed = await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(removed > 0
                ? '$label — cleaned $removed item${removed == 1 ? '' : 's'}'
                : '$label — nothing to clean'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = ref.read(downloadManagerProvider);
    return SettingsCard(
      title: 'Disk Cleanup',
      icon: Icons.cleaning_services_rounded,
      accent: const Color(0xFFEF4444),
      children: [
        ListTile(
          title: const Text('Remove orphaned temp files'),
          subtitle: const Text('Delete temp data from deleted or finished downloads'),
          trailing: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.cleaning_services_rounded),
          onTap: () => _run('Orphan cleanup', manager.cleanOrphanTempFiles),
        ),
        ListTile(
          title: const Text('Remove unfinished download data'),
          subtitle: const Text(
            'Deletes partial data for downloads that are not running — frees space taken by half-downloaded files',
          ),
          trailing: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.delete_sweep_rounded),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Remove unfinished data?'),
                content: const Text(
                  'Partial data for paused, queued and failed downloads will be deleted. '
                  'Those downloads will restart from zero next time they run.',
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
                ],
              ),
            );
            if (confirmed == true) {
              await _run('Unfinished data removed', manager.clearUnfinishedTempData);
            }
          },
        ),
      ],
    );
  }
}

class _AppearanceTab extends ConsumerWidget {
  const _AppearanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return _SettingsList(children: [
      SettingsCard(
        title: 'Theme',
        icon: Icons.palette_rounded,
        children: [
          ListTile(
            title: const Text('Theme'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode, size: 16)),
                ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.settings, size: 16)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode, size: 16)),
              ],
              selected: {themeMode},
              onSelectionChanged: (modes) {
                ref.read(themeModeProvider.notifier).setThemeMode(modes.first);
              },
            ),
          ),
          ListTile(
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fa', child: Text('فارسی')),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(v));
                }
              },
            ),
          ),
        ],
      ),
    ]);
  }
}

class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(allCategoriesProvider);

    return categories.when(
      data: (list) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Category'),
                  onPressed: () => _showCategoryEditor(context, ref, null),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final cat = list[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(cat.name),
                    subtitle: Text(cat.fileExtensions, style: const TextStyle(fontSize: 11)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => _showCategoryEditor(context, ref, cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () {
                            ref.read(categoryRepositoryProvider).deleteCategory(cat.id!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _showCategoryEditor(BuildContext context, WidgetRef ref, DownloadCategory? existing) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final extController = TextEditingController(text: existing?.fileExtensions ?? '');
    final pathController = TextEditingController(text: existing?.defaultSavePath ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? 'Edit Category' : 'Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(
              controller: extController,
              decoration: const InputDecoration(
                labelText: 'Extensions',
                hintText: '.pdf,.doc,.txt',
              ),
            ),
            const SizedBox(height: 8),
            TextField(controller: pathController, decoration: const InputDecoration(labelText: 'Default save path')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final cat = DownloadCategory(
                id: existing?.id,
                name: nameController.text,
                fileExtensions: extController.text,
                defaultSavePath: pathController.text,
              );
              final repo = ref.read(categoryRepositoryProvider);
              if (existing != null) {
                repo.updateCategory(cat);
              } else {
                repo.insertCategory(cat);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _AdvancedTab extends ConsumerStatefulWidget {
  const _AdvancedTab();

  @override
  ConsumerState<_AdvancedTab> createState() => _AdvancedTabState();
}

class _AdvancedTabState extends ConsumerState<_AdvancedTab> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = '${info.version} (${info.buildNumber})');
      }
    } catch (_) {
      if (mounted) setState(() => _version = AppConstants.appVersion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(allSettingsProvider);

    return settings.when(
      data: (map) => _SettingsList(children: [
        SettingsCard(
          title: 'Speed & Notifications',
          icon: Icons.notifications_rounded,
          children: [
            SwitchListTile(
              title: const Text('Speed limit enabled'),
              value: map[AppSettings.speedLimitEnabled] == 'true',
              onChanged: (v) {
                ref.read(settingsRepositoryProvider).setBoolValue(AppSettings.speedLimitEnabled, v);
                ref.invalidate(allSettingsProvider);
              },
            ),
            if (map[AppSettings.speedLimitEnabled] == 'true')
              ListTile(
                title: const Text('Speed limit (KB/s)'),
                subtitle: Text('${(int.tryParse(map[AppSettings.speedLimitValue] ?? '0') ?? 0) ~/ 1024} KB/s'),
                trailing: SizedBox(
                  width: 200,
                  child: Slider(
                    value: ((int.tryParse(map[AppSettings.speedLimitValue] ?? '0') ?? 0) / 1024).clamp(0, 10240),
                    min: 0,
                    max: 10240,
                    divisions: 100,
                    onChanged: (v) {
                      ref.read(settingsRepositoryProvider).setIntValue(AppSettings.speedLimitValue, (v * 1024).round());
                      ref.invalidate(allSettingsProvider);
                    },
                  ),
                ),
              ),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Notify when a download finishes or fails'),
              value: map[AppSettings.notificationsEnabled] == 'true',
              onChanged: (v) {
                ref.read(settingsRepositoryProvider).setBoolValue(AppSettings.notificationsEnabled, v);
                ref.invalidate(allSettingsProvider);
              },
            ),
            SwitchListTile(
              title: const Text('Sound on complete'),
              value: map[AppSettings.soundOnComplete] == 'true',
              onChanged: (v) {
                ref.read(settingsRepositoryProvider).setBoolValue(AppSettings.soundOnComplete, v);
                ref.invalidate(allSettingsProvider);
              },
            ),
          ],
        ),
        SettingsCard(
          title: 'Identity',
          icon: Icons.fingerprint_rounded,
          accent: const Color(0xFF06B6D4),
          children: [
            ListTile(
              title: const Text('User-Agent string'),
              subtitle: Text(
                map[AppSettings.userAgent] ?? AppConstants.defaultUserAgent,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
              onTap: () => _editUserAgent(context, ref, map[AppSettings.userAgent] ?? AppConstants.defaultUserAgent),
            ),
          ],
        ),
        SettingsCard(
          title: 'About',
          icon: Icons.info_rounded,
          accent: const Color(0xFF10B981),
          children: [
            ListTile(
              leading: Image.asset(
                'assets/icons/hi-dm-logo.png',
                width: 36,
                height: 36,
              ),
              title: const Text('HI-DM'),
              subtitle: Text('Version ${_version.isEmpty ? AppConstants.appVersion : _version}'),
            ),
          ],
        ),
      ]),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _editUserAgent(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('User-Agent'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(settingsRepositoryProvider).setValue(AppSettings.userAgent, controller.text);
              ref.invalidate(allSettingsProvider);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// Scrollable, padded content column shared by all sections.
class _SettingsList extends StatelessWidget {
  final List<Widget> children;
  const _SettingsList({required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }
}
