import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Render a first frame before waiting for filesystem or platform services.
class StartupGate extends StatefulWidget {
  final Future<void> Function() initialize;
  final Future<void> Function() initializeNotifications;
  final Widget child;

  const StartupGate({
    super.key,
    required this.initialize,
    required this.initializeNotifications,
    required this.child,
  });

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _ready = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!mounted) return;
    setState(() => _error = null);
    try {
      await widget.initialize();
      if (!mounted) return;
      setState(() => _ready = true);
      // Permission prompts are optional and must never gate the first screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          Future<void>.sync(
            widget.initializeNotifications,
          ).timeout(const Duration(seconds: 10)).catchError((Object error) {
            debugPrint('[HI-DM] Notification init error (non-fatal): $error');
          }),
        );
      });
    } catch (error, stack) {
      debugPrint('[HI-DM] Startup error: $error\n$stack');
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;
    return MaterialApp(
      title: 'HI-DM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error == null) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text('Starting HI-DM…'),
                ] else ...[
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 20),
                  const Text('Unable to start HI-DM'),
                  const SizedBox(height: 12),
                  SelectableText('$_error', textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: _start, child: const Text('Retry')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
