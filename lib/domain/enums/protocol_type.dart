enum ProtocolType {
  http,
  https,
  ftp;

  String get label {
    switch (this) {
      case ProtocolType.http: return 'HTTP';
      case ProtocolType.https: return 'HTTPS';
      case ProtocolType.ftp: return 'FTP';
    }
  }
}
