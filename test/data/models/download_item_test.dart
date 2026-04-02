import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/data/models/download_item.dart';
import 'package:flutter_dm/data/models/proxy_config.dart';

void main() {
  group('DownloadItem', () {
    test('progress is 0 when totalSize is 0', () {
      final item = DownloadItem(
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        savePath: '/tmp',
        dateAdded: DateTime.now(),
        totalSize: 0,
        downloadedSize: 0,
      );
      expect(item.progress, 0);
    });

    test('progress calculates correctly', () {
      final item = DownloadItem(
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        savePath: '/tmp',
        dateAdded: DateTime.now(),
        totalSize: 1000,
        downloadedSize: 500,
      );
      expect(item.progress, 0.5);
    });

    test('isCompleted returns true for completed status', () {
      final item = DownloadItem(
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        savePath: '/tmp',
        dateAdded: DateTime.now(),
        status: 'completed',
      );
      expect(item.isCompleted, true);
    });

    test('isActive returns true for downloading', () {
      final item = DownloadItem(
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        savePath: '/tmp',
        dateAdded: DateTime.now(),
        status: 'downloading',
      );
      expect(item.isActive, true);
    });

    test('eta calculates correctly', () {
      final item = DownloadItem(
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        savePath: '/tmp',
        dateAdded: DateTime.now(),
        totalSize: 1000,
        downloadedSize: 500,
        speed: 100,
      );
      expect(item.eta, const Duration(seconds: 5));
    });

    test('eta is null when speed is 0', () {
      final item = DownloadItem(
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        savePath: '/tmp',
        dateAdded: DateTime.now(),
        totalSize: 1000,
        downloadedSize: 500,
        speed: 0,
      );
      expect(item.eta, null);
    });

    test('headers JSON round-trip', () {
      final headers = {'Cookie': 'abc=123', 'Referer': 'https://example.com'};
      final item = DownloadItem(
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        savePath: '/tmp',
        dateAdded: DateTime.now(),
        headers: headers,
      );
      final json = item.headersJson;
      final parsed = DownloadItem.headersFromJson(json);
      expect(parsed, headers);
    });

    test('copyWith preserves fields', () {
      final item = DownloadItem(
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        savePath: '/tmp',
        dateAdded: DateTime.now(),
        threadCount: 8,
      );
      final updated = item.copyWith(status: 'downloading', speed: 1024);
      expect(updated.status, 'downloading');
      expect(updated.speed, 1024);
      expect(updated.fileName, 'file.zip');
      expect(updated.threadCount, 8);
    });
  });

  group('ProxyConfig', () {
    test('JSON round-trip', () {
      const config = ProxyConfig(
        type: 'socks5',
        host: '127.0.0.1',
        port: 1080,
        username: 'user',
        password: 'pass',
      );
      final json = config.encode();
      final decoded = ProxyConfig.decode(json);
      expect(decoded.type, 'socks5');
      expect(decoded.host, '127.0.0.1');
      expect(decoded.port, 1080);
      expect(decoded.username, 'user');
      expect(decoded.password, 'pass');
    });

    test('none factory', () {
      final config = ProxyConfig.none();
      expect(config.type, 'none');
      expect(config.host, '');
      expect(config.port, 0);
    });
  });
}
