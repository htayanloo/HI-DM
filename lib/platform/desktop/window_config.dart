import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowConfig with WindowListener {
  WindowConfig._();

  static final WindowConfig instance = WindowConfig._();

  /// Invoked when the user tries to close the window (titlebar X, tray quit,
  /// Cmd+Q on macOS, etc.). The app is prevented from closing natively, so
  /// this callback must perform a graceful shutdown and terminate the process.
  Future<void> Function()? onCloseRequested;

  /// Invoked after the native minimize event — lets the app hide to tray
  /// when the "Minimize to tray" setting is enabled.
  Future<void> Function()? onMinimizeRequested;

  static bool get _isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  static Future<void> initialize() async {
    if (!_isDesktop) return;

    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1100, 700),
      minimumSize: Size(800, 500),
      center: true,
      title: 'HI-DM',
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // Take over the close event so we can flush state, stop isolates and
    // terminate the process instead of leaving a background zombie.
    try {
      await windowManager.setPreventClose(true);
      windowManager.addListener(instance);
    } catch (e) {
      debugPrint('[Window] preventClose setup error (non-fatal): $e');
    }
  }

  static Future<void> setTitle(String title) async {
    if (!_isDesktop) return;
    await windowManager.setTitle(title);
  }

  static Future<void> minimize() async {
    if (!_isDesktop) return;
    await windowManager.minimize();
  }

  static Future<void> maximize() async {
    if (!_isDesktop) return;
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  /// Request a close — routed through the graceful shutdown callback when
  /// registered, otherwise falls back to a native close.
  static Future<void> close() async {
    if (!_isDesktop) return;
    final handler = instance.onCloseRequested;
    if (handler != null) {
      await handler();
    } else {
      await windowManager.close();
    }
  }

  @override
  void onWindowClose() async {
    final handler = onCloseRequested;
    if (handler != null) {
      await handler();
    } else {
      await windowManager.destroy();
      exit(0);
    }
  }

  @override
  void onWindowMinimize() {
    onMinimizeRequested?.call();
  }
}
