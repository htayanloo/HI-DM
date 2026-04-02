class AppConstants {
  static const String appName = 'HI-DM';
  static const String appVersion = '1.4.0';

  // Download defaults
  static const int defaultThreadCount = 8;
  static const int maxThreadCount = 32;
  static const int minThreadCount = 1;
  static const int defaultMaxConcurrentDownloads = 3;

  // Connection
  static const int defaultConnectionTimeout = 30; // seconds
  static const int defaultRetryCount = 5;
  static const int defaultRetryDelay = 5; // seconds

  // Clipboard
  static const int clipboardPollInterval = 500; // milliseconds

  // Speed calculation
  static const int speedSampleWindow = 5; // seconds for rolling average

  // Scheduler
  static const int schedulerCheckInterval = 30; // seconds

  // Database
  static const String databaseName = 'hi_dm.db';
  static const int databaseVersion = 1;

  // Temp file prefix
  static const String tempFilePrefix = 'fdm_seg_';

  // User agent
  static const String defaultUserAgent = 'HI-DM/1.0';
}
