import 'dart:async';

import 'package:flutter/services.dart';

import '../../core/utils/url_utils.dart';

class ClipboardMonitor {
  Timer? _timer;
  String? _lastUrl;
  bool enabled = true;
  final void Function(String url) onUrlDetected;

  ClipboardMonitor({required this.onUrlDetected});

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _check());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _check() async {
    if (!enabled) return;

    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text == null || text.isEmpty) return;
      if (text == _lastUrl) return;
      if (!UrlUtils.isValidUrl(text)) return;

      _lastUrl = text;
      onUrlDetected(text);
    } catch (_) {
      // Clipboard access can fail on some platforms
    }
  }

  void dispose() {
    stop();
  }
}
