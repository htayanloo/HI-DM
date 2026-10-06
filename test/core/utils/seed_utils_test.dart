import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/core/utils/seed_utils.dart';
import 'package:flutter_dm/data/models/app_settings.dart';

void main() {
  group('SeedUtils.shouldSeedSavePath', () {
    const container = '/Users/me/Library/Containers/com.hidm.app/Data';

    test('never overwrites a user-customized path', () {
      expect(
        SeedUtils.shouldSeedSavePath(
          customized: true,
          currentPath: '/Users/me/My Movies',
          containerHome: container,
        ),
        isFalse,
      );
    });

    test('customized wins even when the path is empty', () {
      expect(
        SeedUtils.shouldSeedSavePath(
          customized: true,
          currentPath: '',
          containerHome: container,
        ),
        isFalse,
      );
    });

    test('seeds when no path has ever been set', () {
      expect(
        SeedUtils.shouldSeedSavePath(
          customized: false,
          currentPath: '',
          containerHome: container,
        ),
        isTrue,
      );
    });

    test('re-seeds an app-generated path inside the sandbox container', () {
      expect(
        SeedUtils.shouldSeedSavePath(
          customized: false,
          currentPath: '$container/Downloads/HI-DM',
          containerHome: container,
        ),
        isTrue,
      );
    });

    test('keeps a normal path chosen before the flag existed', () {
      expect(
        SeedUtils.shouldSeedSavePath(
          customized: false,
          currentPath: '/Users/me/Downloads/KeepMe',
          containerHome: container,
        ),
        isFalse,
      );
    });

    test('does not match a container prefix that is only a substring', () {
      expect(
        SeedUtils.shouldSeedSavePath(
          customized: false,
          currentPath: '/Users/me/Downloads/Containers-backup',
          containerHome: container,
        ),
        isFalse,
      );
    });

    test('handles empty/absent container home safely', () {
      expect(
        SeedUtils.shouldSeedSavePath(
          customized: false,
          currentPath: '/Users/me/Downloads/HI-DM',
          containerHome: '',
        ),
        isFalse,
      );
      // A bare "/" container home must never match everything.
      expect(
        SeedUtils.shouldSeedSavePath(
          customized: false,
          currentPath: '/Users/me/Downloads/HI-DM',
          containerHome: '/',
        ),
        isFalse,
      );
    });
  });

  group('AppSettings new keys', () {
    test('queue_order defaults to fifo', () {
      expect(AppSettings.defaults[AppSettings.queueOrder], 'fifo');
    });

    test('save_path_customized defaults to false', () {
      expect(AppSettings.defaults[AppSettings.savePathCustomized], 'false');
    });

    test('notifications default to enabled', () {
      expect(AppSettings.defaults[AppSettings.notificationsEnabled], 'true');
    });
  });
}
