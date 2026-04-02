import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/download_category.dart';
import '../../providers/category_providers.dart';
import '../../providers/locale_provider.dart';
import '../../providers/settings_providers.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Connection'),
            Tab(text: 'Downloads'),
            Tab(text: 'Appearance'),
            Tab(text: 'Categories'),
            Tab(text: 'Advanced'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GeneralTab(),
          _ConnectionTab(),
          _DownloadsTab(),
          _AppearanceTab(),
          _CategoriesTab(),
          _AdvancedTab(),
        ],
      ),
    );
  }
}

class _GeneralTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(allSettingsProvider);

    return settings.when(
      data: (map) => ListView(
        padding: const EdgeInsets.all(16),
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
          SwitchListTile(
            title: const Text('Minimize to tray'),
            value: map[AppSettings.minimizeToTray] == 'true',
            onChanged: (v) {
              ref.read(settingsRepositoryProvider).setBoolValue(AppSettings.minimizeToTray, v);
              ref.invalidate(allSettingsProvider);
            },
          ),
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
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ConnectionTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(allSettingsProvider);

    return settings.when(
      data: (map) => ListView(
        padding: const EdgeInsets.all(16),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _DownloadsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(allSettingsProvider);

    return settings.when(
      data: (map) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Default save path'),
            subtitle: Text(map[AppSettings.defaultSavePath]?.isNotEmpty == true
                ? map[AppSettings.defaultSavePath]!
                : 'Not set'),
            trailing: IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () async {
                final path = await FilePicker.platform.getDirectoryPath();
                if (path != null) {
                  ref.read(settingsRepositoryProvider).setValue(AppSettings.defaultSavePath, path);
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _AppearanceTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
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
    );
  }
}

class _CategoriesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(allCategoriesProvider);

    return categories.when(
      data: (list) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
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
              itemCount: list.length,
              itemBuilder: (_, i) {
                final cat = list[i];
                return ListTile(
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

class _AdvancedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(allSettingsProvider);

    return settings.when(
      data: (map) => ListView(
        padding: const EdgeInsets.all(16),
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
          ListTile(
            title: const Text('User-Agent string'),
            subtitle: Text(
              map[AppSettings.userAgent] ?? AppConstants.defaultUserAgent,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
            onTap: () => _editUserAgent(context, ref, map[AppSettings.userAgent] ?? AppConstants.defaultUserAgent),
          ),
          const Divider(),
          const ListTile(
            title: Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('HI-DM'),
            subtitle: Text('Version ${AppConstants.appVersion}'),
          ),
        ],
      ),
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
