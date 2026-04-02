import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class LogEntry {
  final DateTime timestamp;
  final String message;

  const LogEntry({required this.timestamp, required this.message});
}

class LogView extends StatefulWidget {
  final List<LogEntry> entries;

  const LogView({super.key, required this.entries});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final _scrollController = ScrollController();
  bool _autoScroll = true;
  final _timeFormat = DateFormat('HH:mm:ss.SSS');

  @override
  void didUpdateWidget(covariant LogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_autoScroll && widget.entries.length > oldWidget.entries.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _copyLog() {
    final text = widget.entries
        .map((e) => '[${_timeFormat.format(e.timestamp)}] ${e.message}')
        .join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log copied to clipboard'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Text('${widget.entries.length} entries',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _autoScroll ? Icons.vertical_align_bottom : Icons.vertical_align_center,
                  size: 18,
                ),
                tooltip: _autoScroll ? 'Auto-scroll ON' : 'Auto-scroll OFF',
                onPressed: () => setState(() => _autoScroll = !_autoScroll),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy log',
                onPressed: _copyLog,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Log entries
        Expanded(
          child: widget.entries.isEmpty
              ? Center(
                  child: Text('No log entries yet',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: widget.entries.length,
                  itemBuilder: (_, i) {
                    final entry = widget.entries[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                          children: [
                            TextSpan(
                              text: '[${_timeFormat.format(entry.timestamp)}] ',
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                            TextSpan(
                              text: entry.message,
                              style: TextStyle(
                                color: entry.message.toLowerCase().contains('error')
                                    ? Colors.red
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
