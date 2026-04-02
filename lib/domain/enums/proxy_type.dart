enum ProxyType {
  none,
  http,
  https,
  socks4,
  socks5;

  String get label {
    switch (this) {
      case ProxyType.none: return 'None';
      case ProxyType.http: return 'HTTP';
      case ProxyType.https: return 'HTTPS';
      case ProxyType.socks4: return 'SOCKS4';
      case ProxyType.socks5: return 'SOCKS5';
    }
  }
}
