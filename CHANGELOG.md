# Changelog

All notable changes to HI-DM will be documented in this file.

## [1.5.1] - 2026-10-05

### Added
- **Watch while downloading (stream mode)** — sequential single-connection
  download that writes straight to the final file, so a partially downloaded
  video can be opened and played while it is still downloading
- **Download-complete / failed notifications** — OS notifications with a
  tap-to-open action (respects the existing Notifications setting)
- **One-click Open File** — open button on finished downloads, "Open File" in
  the right-click menu, and an Open action in the detail screen
- **Queue ordering option** — choose FIFO, LIFO, largest-first, smallest-first
  or name order instead of the fixed oldest-first queue
- **Sort control on the download list** — a sort button in the toolbar (next
  to search) switches the list between oldest first, newest first, largest
  first, smallest first and name A–Z; the choice persists across restarts
- **Disk cleanup** — automatic removal of orphaned temp directories at startup
  and on delete, plus Settings → Downloads → Disk Cleanup with manual
  "orphaned temp files" and "unfinished download data" actions
- Tray/menu-bar now shows live speed, active, queued and completed counts
  while the window is closed or minimized (macOS menu bar shows the speed)
- Settings screen redesigned with sidebar navigation and card-based sections
  matching the main window's visual style
- Version in About now comes from `package_info_plus` (pubspec.yaml) so it can
  never drift from the packaged version again

### Fixed
- **Close button left a background process running** — window close is now
  intercepted, active downloads are paused and flushed, the tray is destroyed
  and the process exits cleanly (no more zombie process)
- **Downloads got stuck after a sudden close or crash** — downloads left in an
  active status with no isolate behind them are re-queued and resumed at
  startup instead of showing a frozen state
- **Downloads hung forever after network loss or laptop sleep** — stall
  watchdog detects a silent connection and retries from the bytes already on
  disk; the retry counter resets whenever progress is made, so flaky but
  alive connections keep downloading
- **Pause now takes effect immediately**, even on a stalled connection
- **Save path reset to the default on every relaunch** — a user-chosen path is
  flagged as customized and is never overwritten at startup; picking a folder
  in the Add dialog also persists it
- **Version mismatch** — pubspec bumped, About screen reads the real build via
  `package_info_plus`, and the hardcoded `AppConstants.appVersion` is now only
  a fallback
- **Corruption on resume** — a server that ignores the `Range` header now
  restarts the file instead of appending a full body to a partial file
- **Premature stream close** — a connection that ends before the segment is
  complete is retried instead of being reported as a finished download
- **Tray icon failed to load on macOS** — `tray_manager` expects a Flutter
  asset path, not an absolute file path
- **Startup crash `duplicate column name: stream_mode`** — the v2→v3 upgrade
  is now idempotent: it checks which columns actually exist before adding
  them, so a stale schema marker can no longer break the launch
- Half-downloaded leftovers no longer accumulate (temp dir removed on delete,
  orphans cleaned at startup)

### Changed
- Settings tabs replaced with a sidebar + card layout consistent with the
  main window
- Analyzer is clean (4 pre-existing lint infos fixed) and the stale widget
  test was updated; suite now covers the download engine end-to-end

## [1.4.0] - 2026-04-03

### Added
- Full README with feature list, installation guide, and architecture docs
- CHANGELOG tracking all versions

### Changed
- Version bump to 1.4.0

## [1.3.1] - 2026-04-03

### Added
- Manual redirect resolver — follows up to 30 redirect hops (301/302/303/307/308)
- Resolves relative `Location` headers
- Catches redirects inside DioException responses

### Fixed
- Complex redirect chains now fully resolved before download starts

## [1.3.0] - 2026-04-02

### Added
- Cookie persistence with `dio_cookie_manager` + `cookie_jar`
- CookieJar shared between URL analyzer and connection pool
- Resolved URL tracking after redirect chains
- HEAD fallback to GET probe when server rejects HEAD (405)
- "Download Again" button in right-click context menu
- Support for cookie-based download services (GapFilm, etc.)

## [1.2.1] - 2026-04-02

### Fixed
- CI/CD workflow: proper DEB/RPM/AppImage/DMG/ZIP packaging
- DEB heredoc indentation fixed
- Dynamic version from `pubspec.yaml` in all packages
- Windows: ZIP archive instead of MSI
- Linux: tar.gz bundle added

## [1.2.0] - 2026-04-02

### Added
- System tray icon with download speed display
- Tray menu: Show Window, Add URL, Pause All, Resume All, Quit
- Tray tooltip shows current download speed
- "Open Folder" in context menu (macOS: `open`, Windows: `explorer`, Linux: `xdg-open`)

### Changed
- All references renamed from FlutterDM to HI-DM
- Bundle ID: `com.hidm.app`
- Custom titlebar with HI-DM logo
- Database name: `hi_dm.db`
- PRODUCT_NAME: HI-DM

## [1.1.0] - 2026-04-02

### Added
- Custom titlebar with HI-DM branding (hidden system titlebar)
- Window drag, double-click maximize, traffic light spacing (macOS)
- Window control buttons for Windows/Linux (minimize, maximize, close)
- HI-DM logo as macOS app icon (all sizes 16-1024px)
- GitHub Actions CI/CD workflow
- Packaging: DEB, RPM, AppImage, DMG, PKGBUILD, Flatpak manifest

### Changed
- App renamed to HI-DM everywhere

## [1.0.0] - 2026-04-01

### Added
- **Download Engine**
  - Multi-threaded downloads (1-32 connections)
  - HTTP Range request segmentation
  - Dynamic segment rebalancing
  - Pause/Resume/Cancel with state preservation
  - Token bucket speed limiter (global + per-download)
  - Isolate-based download processing
  - File assembler with temp file management

- **UI**
  - Modern home screen with card-based download tiles
  - Category sidebar with live counts
  - Add URL dialog with HEAD analysis, auto-categorize
  - Batch download dialog with URL patterns
  - Import from .txt file dialog
  - Download detail screen (segments, speed graph, info, logs)
  - Queue manager with scheduling
  - Site grabber with depth/domain/type filters
  - Settings screen (6 tabs: General, Connection, Downloads, Appearance, Categories, Advanced)
  - Per-download settings dialog (speed limit, connection count)
  - Clipboard monitoring with auto-detect prompt

- **Database**
  - Drift (SQLite) with 5 tables
  - Migration support (schema v2)
  - Throttled batch DB writes to prevent SQLite crashes

- **Platform**
  - macOS, Windows, Linux desktop support
  - Window manager with size/position persistence
  - CLI argument handler
  - Entitlements for file access and network

- **Themes**
  - Indigo/Violet color scheme
  - Dark and Light modes with system auto-detection
  - Material 3 with flex_color_scheme

- **Tests**
  - 68 unit tests covering utils, models, speed limiter
