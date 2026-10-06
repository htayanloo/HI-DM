import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/platform/desktop/window_config.dart';

void main() {
  group('WindowConfig close routing', () {
    test('close() delegates to the registered shutdown handler', () async {
      var handlerCalled = false;
      WindowConfig.instance.onCloseRequested = () async {
        handlerCalled = true;
      };

      // On desktop this must call the handler (graceful quit) rather than
      // the native close, which used to leave the process running.
      await WindowConfig.close();

      expect(handlerCalled, isTrue,
          reason: 'close() must route through the graceful-quit handler');

      WindowConfig.instance.onCloseRequested = null;
    });

    test('onWindowClose event delegates to the registered handler', () async {
      var handlerCalled = false;
      WindowConfig.instance.onCloseRequested = () async {
        handlerCalled = true;
      };

      // Simulates the native "close" event emitted by window_manager when the
      // user clicks the titlebar close button.
      WindowConfig.instance.onWindowClose();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(handlerCalled, isTrue,
          reason: 'the native close event must trigger graceful quit');

      WindowConfig.instance.onCloseRequested = null;
    });

    test('minimize event delegates to the registered handler', () async {
      var minimizeCalled = false;
      WindowConfig.instance.onMinimizeRequested = () async {
        minimizeCalled = true;
      };

      WindowConfig.instance.onWindowMinimize();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(minimizeCalled, isTrue);

      WindowConfig.instance.onMinimizeRequested = null;
    });
  });
}
