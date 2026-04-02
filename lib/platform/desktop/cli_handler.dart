class CliHandler {
  final List<String> args;

  CliHandler(this.args);

  bool get hasUrl => _getArg('add') != null;
  String? get url => _getArg('add');
  String? get savePath => _getArg('path');
  int get threads => int.tryParse(_getArg('threads') ?? '') ?? 8;

  String? _getArg(String name) {
    for (var i = 0; i < args.length; i++) {
      if (args[i] == '--$name' && i + 1 < args.length) {
        return args[i + 1];
      }
    }
    return null;
  }

  bool get isCliMode => args.contains('--cli');
  bool get showHelp => args.contains('--help') || args.contains('-h');

  String get helpText => '''
HI-DM - Internet Download Manager

Usage:
  flutter_dm [options]

Options:
  --add <URL>        Add a download URL
  --path <directory> Save directory
  --threads <count>  Number of connections (1-32, default 8)
  --cli              Run in CLI mode (no GUI)
  --help, -h         Show this help message
''';
}
