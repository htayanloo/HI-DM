class AppSettings {
  final String key;
  final String value;

  const AppSettings({required this.key, required this.value});

  // Typed getters
  int get intValue => int.tryParse(value) ?? 0;
  bool get boolValue => value == 'true';
  double get doubleValue => double.tryParse(value) ?? 0.0;

  // Common setting keys
  static const String defaultThreadCount = 'default_thread_count';
  static const String defaultSavePath = 'default_save_path';
  static const String tempDirectory = 'temp_directory';
  static const String maxConnectionsPerServer = 'max_connections_per_server';
  static const String connectionTimeout = 'connection_timeout';
  static const String retryCount = 'retry_count';
  static const String retryDelay = 'retry_delay';
  static const String clipboardMonitoring = 'clipboard_monitoring';
  static const String startWithOs = 'start_with_os';
  static const String startMinimized = 'start_minimized';
  static const String confirmOnDelete = 'confirm_on_delete';
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String speedLimitEnabled = 'speed_limit_enabled';
  static const String speedLimitValue = 'speed_limit_value';
  static const String userAgent = 'user_agent';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String soundOnComplete = 'sound_on_complete';
  static const String autoCategories = 'auto_categories';
  static const String duplicateHandling = 'duplicate_handling';
  static const String minimizeToTray = 'minimize_to_tray';
  static const String maxConcurrentDownloads = 'max_concurrent_downloads';

  // Default values
  static const Map<String, String> defaults = {
    defaultThreadCount: '8',
    defaultSavePath: '',
    tempDirectory: '',
    maxConnectionsPerServer: '16',
    connectionTimeout: '30',
    retryCount: '5',
    retryDelay: '5',
    clipboardMonitoring: 'true',
    startWithOs: 'false',
    startMinimized: 'false',
    confirmOnDelete: 'true',
    themeMode: 'system',
    locale: 'en',
    speedLimitEnabled: 'false',
    speedLimitValue: '0',
    userAgent: 'HI-DM/1.0',
    notificationsEnabled: 'true',
    soundOnComplete: 'true',
    autoCategories: 'true',
    duplicateHandling: 'ask',
    minimizeToTray: 'true',
    maxConcurrentDownloads: '3',
  };
}
