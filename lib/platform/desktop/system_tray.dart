import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/utils/speed_formatter.dart';

/// System tray integration — shows HI-DM icon in system tray
/// with download speed and controls.
class SystemTrayService with TrayListener {
  static final SystemTrayService _instance = SystemTrayService._();
  factory SystemTrayService() => _instance;
  SystemTrayService._();

  bool _initialized = false;
  double _currentSpeed = 0;
  int _activeCount = 0;
  Timer? _updateTimer;

  VoidCallback? onShowWindow;
  VoidCallback? onPauseAll;
  VoidCallback? onResumeAll;
  VoidCallback? onAddUrl;
  VoidCallback? onQuit;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;

    try {
      trayManager.addListener(this);

      // Extract tray icon from Flutter assets to a temp file
      // tray_manager needs an absolute file path, not a Flutter asset path
      final iconPath = await _extractTrayIcon();

      await trayManager.setIcon(iconPath, isTemplate: false);
      // Show title next to icon in menu bar
      if (Platform.isMacOS) {
        await trayManager.setTitle('HI-DM');
      }
      await _updateMenu();
      await trayManager.setToolTip('HI-DM — Download Manager');

      _initialized = true;
      debugPrint('[Tray] System tray initialized with icon: $iconPath');
    } catch (e) {
      debugPrint('[Tray] Failed to initialize: $e');
    }
  }

  /// Get the tray icon — resolve from app bundle or copy from assets.
  Future<String> _extractTrayIcon() async {
    // Method 1: Find icon inside the app bundle (works for macOS release & debug)
    if (Platform.isMacOS) {
      final executable = Platform.resolvedExecutable;
      // Go from .app/Contents/MacOS/hi-dm to .app/Contents/Frameworks/App.framework/...
      final appDir = File(executable).parent.parent.path;
      final bundleIcon = File(p.join(
        appDir, 'Frameworks', 'App.framework', 'Versions', 'A',
        'Resources', 'flutter_assets', 'assets', 'icons', 'tray_icon.png',
      ));
      if (await bundleIcon.exists()) {
        debugPrint('[Tray] Using bundle icon: ${bundleIcon.path}');
        return bundleIcon.path;
      }
    }

    // Method 2: Copy from project source (debug fallback)
    final tempDir = await getApplicationSupportDirectory();
    final iconFile = File(p.join(tempDir.path, 'tray_icon.png'));

    if (!await iconFile.exists()) {
      // Try project source
      for (final srcPath in ['assets/icons/tray_icon.png', 'assets/icons/hi-dm-logo.png']) {
        final src = File(srcPath);
        if (await src.exists()) {
          await iconFile.create(recursive: true);
          await src.copy(iconFile.path);
          break;
        }
      }
    }

    return iconFile.path;
  }

  /// Update the tray with current download stats.
  void updateStats({required double totalSpeed, required int activeDownloads}) {
    _currentSpeed = totalSpeed;
    _activeCount = activeDownloads;

    // Throttle menu updates to every 2 seconds
    _updateTimer ??= Timer(const Duration(seconds: 2), () {
      _updateTimer = null;
      _updateMenu();
    });
  }

  Future<void> _updateMenu() async {
    if (!_initialized) return;

    try {
      final speedText = _currentSpeed > 0
          ? SpeedFormatter.format(_currentSpeed)
          : 'Idle';
      final activeText = _activeCount > 0
          ? '$_activeCount active download${_activeCount > 1 ? 's' : ''}'
          : 'No active downloads';

      // Update tooltip with speed
      await trayManager.setToolTip('HI-DM — $speedText');

      // Build menu
      final menu = Menu(
        items: [
          MenuItem(label: 'HI-DM — $speedText', disabled: true),
          MenuItem(label: activeText, disabled: true),
          MenuItem.separator(),
          MenuItem(label: 'Show Window', key: 'show'),
          MenuItem(label: 'Add URL...', key: 'add'),
          MenuItem.separator(),
          MenuItem(label: 'Resume All', key: 'resume'),
          MenuItem(label: 'Pause All', key: 'pause'),
          MenuItem.separator(),
          MenuItem(label: 'Quit HI-DM', key: 'quit'),
        ],
      );

      await trayManager.setContextMenu(menu);
    } catch (e) {
      debugPrint('[Tray] Menu update error: $e');
    }
  }

  @override
  void onTrayIconMouseDown() {
    _showWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        _showWindow();
        break;
      case 'add':
        _showWindow();
        onAddUrl?.call();
        break;
      case 'resume':
        onResumeAll?.call();
        break;
      case 'pause':
        onPauseAll?.call();
        break;
      case 'quit':
        onQuit?.call();
        break;
    }
  }

  void _showWindow() async {
    try {
      await windowManager.show();
      await windowManager.focus();
    } catch (_) {}
  }

  void dispose() {
    _updateTimer?.cancel();
    trayManager.removeListener(this);
    try {
      trayManager.destroy();
    } catch (_) {}
  }
}
