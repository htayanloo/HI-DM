import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
  int _queuedCount = 0;
  int _completedCount = 0;
  Timer? _updateTimer;
  String _lastTitle = '';

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

      // tray_manager resolves the icon itself: on macOS it loads the path via
      // rootBundle, on Windows/Linux it prefixes `data/flutter_assets/`.
      // So a Flutter asset path (relative to the assets dir) is what works on
      // every desktop platform — an absolute file path breaks macOS.
      await trayManager.setIcon('assets/icons/tray_icon.png', isTemplate: false);

      // Show title next to icon in menu bar
      if (Platform.isMacOS) {
        await trayManager.setTitle('HI-DM');
      }
      await _updateMenu();
      await trayManager.setToolTip('HI-DM — Download Manager');

      _initialized = true;
      debugPrint('[Tray] System tray initialized');
    } catch (e) {
      debugPrint('[Tray] Failed to initialize: $e');
    }
  }

  /// Update the tray with current download stats.
  ///
  /// [queuedCount]/[completedCount] enrich the OS status-bar details shown
  /// while the window is closed/minimized.
  void updateStats({
    required double totalSpeed,
    required int activeDownloads,
    int queuedCount = 0,
    int completedCount = 0,
  }) {
    _currentSpeed = totalSpeed;
    _activeCount = activeDownloads;
    _queuedCount = queuedCount;
    _completedCount = completedCount;

    // Throttle menu/title updates to every 2 seconds
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
      final queueText = '$_queuedCount queued • $_completedCount completed';

      // macOS menu bar: show live speed so status is visible even when the
      // window is closed (top of screen = OS status bar).
      if (Platform.isMacOS) {
        final title = _activeCount > 0 ? speedText : '';
        if (title != _lastTitle) {
          _lastTitle = title;
          await trayManager.setTitle(title);
        }
      }

      // Update tooltip with speed
      await trayManager.setToolTip('HI-DM — $speedText');

      // Build menu
      final menu = Menu(
        items: [
          MenuItem(label: 'HI-DM — $speedText', disabled: true),
          MenuItem(label: activeText, disabled: true),
          MenuItem(label: queueText, disabled: true),
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
