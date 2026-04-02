enum PostAction {
  nothing,
  disconnect,
  shutdown,
  hibernate,
  sleep,
  runProgram;

  String get label {
    switch (this) {
      case PostAction.nothing: return 'Do Nothing';
      case PostAction.disconnect: return 'Disconnect';
      case PostAction.shutdown: return 'Shutdown';
      case PostAction.hibernate: return 'Hibernate';
      case PostAction.sleep: return 'Sleep';
      case PostAction.runProgram: return 'Run Program';
    }
  }
}
