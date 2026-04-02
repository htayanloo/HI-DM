import 'dart:convert';

class ProxyConfig {
  final String type; // none, http, https, socks4, socks5
  final String host;
  final int port;
  final String? username;
  final String? password;

  const ProxyConfig({
    required this.type,
    required this.host,
    required this.port,
    this.username,
    this.password,
  });

  factory ProxyConfig.none() => const ProxyConfig(type: 'none', host: '', port: 0);

  Map<String, dynamic> toJson() => {
    'type': type,
    'host': host,
    'port': port,
    'username': username,
    'password': password,
  };

  factory ProxyConfig.fromJson(Map<String, dynamic> json) => ProxyConfig(
    type: json['type'] as String,
    host: json['host'] as String,
    port: json['port'] as int,
    username: json['username'] as String?,
    password: json['password'] as String?,
  );

  String encode() => jsonEncode(toJson());
  static ProxyConfig decode(String source) => ProxyConfig.fromJson(jsonDecode(source) as Map<String, dynamic>);

  ProxyConfig copyWith({
    String? type,
    String? host,
    int? port,
    String? username,
    String? password,
  }) => ProxyConfig(
    type: type ?? this.type,
    host: host ?? this.host,
    port: port ?? this.port,
    username: username ?? this.username,
    password: password ?? this.password,
  );
}
