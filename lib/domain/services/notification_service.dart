import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/utils/open_utils.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      settings,
      // Tapping a "Download Complete" notification opens the file.
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        final opened = await OpenUtils.openFile(payload);
        if (!opened) {
          debugPrint('[Notify] Could not open file from notification: $payload');
        }
      },
    );

    // On macOS/iOS the permission prompt is separate from initialization.
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, sound: true, badge: false);
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, sound: true, badge: false);
    } catch (e) {
      debugPrint('[Notify] Permission request error (non-fatal): $e');
    }

    _initialized = true;
    debugPrint('[Notify] Notification service initialized');
  }

  static const NotificationDetails _completeDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'downloads',
      'Downloads',
      channelDescription: 'Download completion notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
    macOS: DarwinNotificationDetails(),
    linux: LinuxNotificationDetails(),
  );

  static const NotificationDetails _errorDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'downloads',
      'Downloads',
      channelDescription: 'Download error notifications',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
    macOS: DarwinNotificationDetails(),
    linux: LinuxNotificationDetails(),
  );

  static Future<void> showDownloadComplete(
    String fileName, {
    String? filePath,
  }) async {
    if (!_initialized) return;

    try {
      await _plugin.show(
        fileName.hashCode,
        'Download Complete',
        fileName,
        _completeDetails,
        payload: filePath,
      );
    } catch (e) {
      debugPrint('[Notify] showDownloadComplete error (non-fatal): $e');
    }
  }

  static Future<void> showDownloadError(String fileName, String error) async {
    if (!_initialized) return;

    try {
      await _plugin.show(
        fileName.hashCode + 1,
        'Download Failed',
        '$fileName: $error',
        _errorDetails,
      );
    } catch (e) {
      debugPrint('[Notify] showDownloadError error (non-fatal): $e');
    }
  }
}
