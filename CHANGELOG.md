# Changelog

All notable changes to HI-DM will be documented in this file.

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
