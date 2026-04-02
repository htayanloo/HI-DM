import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/core/utils/file_utils.dart';

void main() {
  group('FileUtils', () {
    group('getExtension', () {
      test('extracts .zip', () {
        expect(FileUtils.getExtension('file.zip'), '.zip');
      });

      test('extracts .tar.gz last part', () {
        expect(FileUtils.getExtension('archive.tar.gz'), '.gz');
      });

      test('returns empty for no extension', () {
        expect(FileUtils.getExtension('README'), '');
      });
    });

    group('getFileNameFromUrl', () {
      test('extracts filename from simple URL', () {
        expect(FileUtils.getFileNameFromUrl('https://example.com/file.zip'), 'file.zip');
      });

      test('extracts filename from path', () {
        expect(FileUtils.getFileNameFromUrl('https://example.com/downloads/image.png'), 'image.png');
      });

      test('handles URL-encoded names', () {
        expect(FileUtils.getFileNameFromUrl('https://example.com/my%20file.pdf'), 'my file.pdf');
      });

      test('generates fallback for no filename', () {
        final name = FileUtils.getFileNameFromUrl('https://example.com/');
        expect(name, startsWith('download_'));
      });
    });

    group('sanitizeFileName', () {
      test('removes invalid characters', () {
        expect(FileUtils.sanitizeFileName('file<>:name.txt'), 'file___name.txt');
      });

      test('keeps valid characters', () {
        expect(FileUtils.sanitizeFileName('my-file_v2.0.zip'), 'my-file_v2.0.zip');
      });
    });

    group('getUniqueFileName', () {
      test('generates numbered filename', () {
        expect(FileUtils.getUniqueFileName('file.zip', 1), 'file(1).zip');
      });

      test('generates with higher counter', () {
        expect(FileUtils.getUniqueFileName('photo.jpg', 5), 'photo(5).jpg');
      });
    });
  });
}
