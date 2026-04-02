import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// WebSocket-based browser extension integration service.
/// Listens for download requests from browser extensions.
class BrowserIntegration {
  HttpServer? _server;
  final int port;
  final void Function(String url, Map<String, String> headers)? onDownloadRequest;

  BrowserIntegration({
    this.port = 9614,
    this.onDownloadRequest,
  });

  Future<void> start() async {
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      _server!.listen(_handleRequest);
    } catch (e) {
      // Port may be in use — silently fail
    }
  }

  void _handleRequest(HttpRequest request) async {
    // CORS headers for browser extension communication
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = 200;
      await request.response.close();
      return;
    }

    if (request.method == 'POST' && request.uri.path == '/download') {
      try {
        final body = await utf8.decoder.bind(request).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final url = data['url'] as String?;
        final headers = (data['headers'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v.toString())) ?? {};

        if (url != null) {
          onDownloadRequest?.call(url, headers);
          request.response.statusCode = 200;
          request.response.write('{"status": "ok"}');
        } else {
          request.response.statusCode = 400;
          request.response.write('{"error": "missing url"}');
        }
      } catch (e) {
        request.response.statusCode = 500;
        request.response.write('{"error": "$e"}');
      }
    } else if (request.method == 'GET' && request.uri.path == '/ping') {
      request.response.statusCode = 200;
      request.response.write('{"status": "HI-DM running"}');
    } else {
      request.response.statusCode = 404;
    }

    await request.response.close();
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
  }

  void dispose() {
    stop();
  }
}
