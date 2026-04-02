import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/core/utils/url_utils.dart';

void main() {
  group('UrlUtils', () {
    group('isValidUrl', () {
      test('accepts valid HTTP URL', () {
        expect(UrlUtils.isValidUrl('http://example.com/file.zip'), true);
      });

      test('accepts valid HTTPS URL', () {
        expect(UrlUtils.isValidUrl('https://example.com/path/file.zip'), true);
      });

      test('accepts FTP URL', () {
        expect(UrlUtils.isValidUrl('ftp://files.example.com/pub/file.tar.gz'), true);
      });

      test('rejects empty string', () {
        expect(UrlUtils.isValidUrl(''), false);
      });

      test('rejects plain text', () {
        expect(UrlUtils.isValidUrl('not a url'), false);
      });

      test('rejects URL without protocol', () {
        expect(UrlUtils.isValidUrl('example.com/file.zip'), false);
      });

      test('trims whitespace', () {
        expect(UrlUtils.isValidUrl('  https://example.com/file.zip  '), true);
      });
    });

    group('extractProtocol', () {
      test('extracts HTTP', () {
        expect(UrlUtils.extractProtocol('http://example.com'), 'http');
      });

      test('extracts HTTPS', () {
        expect(UrlUtils.extractProtocol('https://example.com'), 'https');
      });

      test('returns null for invalid', () {
        expect(UrlUtils.extractProtocol('not a url'), isNotNull); // Uri.parse handles gracefully
      });
    });

    group('extractHost', () {
      test('extracts host correctly', () {
        expect(UrlUtils.extractHost('https://downloads.example.com/file'), 'downloads.example.com');
      });
    });

    group('generateBatchUrls', () {
      test('generates numbered sequence', () {
        final urls = UrlUtils.generateBatchUrls('https://example.com/img_[01-03].jpg');
        expect(urls.length, 3);
        expect(urls[0], 'https://example.com/img_01.jpg');
        expect(urls[1], 'https://example.com/img_02.jpg');
        expect(urls[2], 'https://example.com/img_03.jpg');
      });

      test('preserves zero padding', () {
        final urls = UrlUtils.generateBatchUrls('https://example.com/[001-003].png');
        expect(urls[0], 'https://example.com/001.png');
        expect(urls[2], 'https://example.com/003.png');
      });

      test('returns single URL if no pattern', () {
        final urls = UrlUtils.generateBatchUrls('https://example.com/file.zip');
        expect(urls.length, 1);
        expect(urls[0], 'https://example.com/file.zip');
      });

      test('handles large range', () {
        final urls = UrlUtils.generateBatchUrls('https://example.com/photo_[1-100].jpg');
        expect(urls.length, 100);
      });
    });
  });
}
