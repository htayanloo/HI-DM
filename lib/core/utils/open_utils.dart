import 'dart:io';

import 'package:flutter/foundation.dart';

/// Opens files and folders with the OS default application.
class OpenUtils {
  /// Open a file with the system default application.
  /// Returns true if the open command was launched successfully.
  static Future<bool> openFile(String path) async {
    if (path.isEmpty) return false;
    try {
      final file = File(path);
      if (!await file.exists()) return false;

      if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', path], runInShell: true);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      } else {
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('[OpenUtils] Failed to open file $path: $e');
      return false;
    }
  }

  /// Open a folder, optionally revealing [filePath] inside it.
  static Future<bool> openFolder(String path, {String? filePath}) async {
    if (path.isEmpty) return false;
    try {
      if (Platform.isMacOS) {
        if (filePath != null) {
          await Process.run('open', ['-R', filePath]);
        } else {
          await Process.run('open', [path]);
        }
      } else if (Platform.isWindows) {
        if (filePath != null) {
          await Process.run('explorer', ['/select,', filePath]);
        } else {
          await Process.run('explorer', [path]);
        }
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      } else {
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('[OpenUtils] Failed to open folder $path: $e');
      return false;
    }
  }
}
