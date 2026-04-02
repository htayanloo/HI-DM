import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowConfig {
  static Future<void> initialize() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;

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
  }

  static Future<void> setTitle(String title) async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;
    await windowManager.setTitle(title);
  }

  static Future<void> minimize() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;
    await windowManager.minimize();
  }

  static Future<void> maximize() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  static Future<void> close() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;
    await windowManager.close();
  }
}
