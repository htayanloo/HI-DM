<p align="center">
  <img src="assets/icons/hi-dm-logo.png" width="128" alt="HI-DM Logo">
</p>

<h1 align="center">HI-DM</h1>
<p align="center"><strong>A modern, open-source Internet Download Manager built with Flutter</strong></p>

<p align="center">
  <img src="https://img.shields.io/github/v/release/htayanloo/HI-DM?style=flat-square" alt="Release">
  <img src="https://img.shields.io/github/license/htayanloo/HI-DM?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/Flutter-3.41-02569B?style=flat-square&logo=flutter" alt="Flutter">
</p>

---

## Features

### Download Engine
- **Multi-threaded downloads** — 1 to 32 simultaneous connections per file
- **HTTP Range requests** — split files into segments for parallel downloading
- **Dynamic segment rebalancing** — redistribute work when a segment finishes early
- **Pause / Resume / Cancel** — full state preservation across app restarts
- **Resume interrupted downloads** — picks up exactly where it stopped
- **Per-download speed limit** — throttle individual downloads
- **Per-download connection count** — customize threads for each file
- **Token bucket speed limiter** — smooth, accurate bandwidth control
- **Cookie persistence** — handles cookie-based download services
- **Redirect chain resolver** — follows up to 30 redirect hops (301/302/307/308)
- **Automatic retry** — exponential backoff with configurable max retries

### Download Management
- **Download queues** — multiple named queues with independent settings
- **Queue scheduling** — start/stop queues at specific times and days
- **Auto-categorization** — sorts downloads by file type (Video, Music, Documents, etc.)
- **Custom categories** — user-defined categories with custom save paths
- **Batch download** — URL patterns with `[001-100]` syntax
- **Import from file** — load URL lists from `.txt` files
- **Clipboard monitoring** — auto-detect copied URLs and prompt to download
- **Site grabber** — crawl websites and discover downloadable resources

### User Interface
- **Modern UI** — custom titlebar, gradient accents, card-based design
- **Dark & Light themes** — with system auto-detection
- **Per-segment progress** — IDM-style connection status bars
- **Real-time speed graph** — fl_chart powered speed visualization
- **System tray** — icon with speed display, pause/resume controls
- **Category sidebar** — with live download counts
- **Search & filter** — find downloads by name, URL, or status
- **Right-click context menu** — Resume, Pause, Delete, Copy URL, Open Folder, Download Again, Speed/Connections settings
- **Responsive layout** — adapts to window size

### Settings
- **General** — startup, clipboard monitoring, thread count defaults
- **Connection** — timeout, retry count, retry delay
- **Downloads** — default save path, temp directory, auto-categorize, duplicate handling
- **Appearance** — theme (light/dark/system), language (English/Persian)
- **Categories** — add/edit/delete with custom extensions and save paths
- **Advanced** — speed limit, notifications, user-agent string

### Platform Support
| Platform | Status | Package |
|----------|--------|---------|
| macOS | Supported | `.dmg` |
| Windows | Supported | `.zip` |
| Linux | Supported | `.deb`, `.rpm`, `.AppImage`, `.tar.gz` |
| Arch Linux | Supported | `PKGBUILD` |

---

## Installation

### Download
Get the latest release from [GitHub Releases](https://github.com/htayanloo/HI-DM/releases).

### macOS
```bash
# Download and mount DMG, drag to Applications
open HI-DM.dmg
```

### Linux (Debian/Ubuntu)
```bash
sudo dpkg -i hi-dm_*_amd64.deb
```

### Linux (Fedora/RHEL)
```bash
sudo rpm -i hi-dm-*.x86_64.rpm
```

### Linux (AppImage)
```bash
chmod +x HI-DM-x86_64.AppImage
./HI-DM-x86_64.AppImage
```

### Arch Linux
```bash
makepkg -si
```

### Windows
Extract `HI-DM-Windows.zip` and run `flutter_dm.exe`.

---

## Build from Source

### Prerequisites
- Flutter 3.41+
- Dart 3.11+
- Platform-specific build tools (Xcode for macOS, Visual Studio for Windows)

### Build
```bash
git clone https://github.com/htayanloo/HI-DM.git
cd HI-DM
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build macos --release   # or: windows, linux
```

---

## Architecture

```
lib/
  core/          — Constants, theme, utilities, extensions
  data/          — Models, Drift database, repositories
  domain/        — Enums, download engine, services
  presentation/  — Riverpod providers, screens, widgets
  platform/      — Desktop (window, tray, CLI), mobile
```

**Tech Stack:**
- **State Management:** Riverpod 2.x
- **Database:** Drift (SQLite)
- **HTTP:** Dio with cookie support
- **Download Engine:** Dart isolates (off main thread)
- **UI:** Material 3 with flex_color_scheme
- **Charts:** fl_chart

---

## License

This project is licensed under the GNU General Public License v2.0 — see the [LICENSE](LICENSE) file.

---

<p align="center">Made with Flutter</p>
