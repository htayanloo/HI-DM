import 'dart:convert';

class ScheduleConfig {
  final DateTime? startAt;
  final DateTime? stopAt;
  final bool recurring;
  final List<int> daysOfWeek; // 1=Mon ... 7=Sun
  final Duration? syncInterval;

  const ScheduleConfig({
    this.startAt,
    this.stopAt,
    this.recurring = false,
    this.daysOfWeek = const [],
    this.syncInterval,
  });

  Map<String, dynamic> toJson() => {
    'startAt': startAt?.toIso8601String(),
    'stopAt': stopAt?.toIso8601String(),
    'recurring': recurring,
    'daysOfWeek': daysOfWeek,
    'syncInterval': syncInterval?.inSeconds,
  };

  factory ScheduleConfig.fromJson(Map<String, dynamic> json) => ScheduleConfig(
    startAt: json['startAt'] != null ? DateTime.parse(json['startAt'] as String) : null,
    stopAt: json['stopAt'] != null ? DateTime.parse(json['stopAt'] as String) : null,
    recurring: json['recurring'] as bool? ?? false,
    daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)?.cast<int>() ?? [],
    syncInterval: json['syncInterval'] != null ? Duration(seconds: json['syncInterval'] as int) : null,
  );

  String encode() => jsonEncode(toJson());
  static ScheduleConfig decode(String source) => ScheduleConfig.fromJson(jsonDecode(source) as Map<String, dynamic>);

  ScheduleConfig copyWith({
    DateTime? startAt,
    DateTime? stopAt,
    bool? recurring,
    List<int>? daysOfWeek,
    Duration? syncInterval,
  }) => ScheduleConfig(
    startAt: startAt ?? this.startAt,
    stopAt: stopAt ?? this.stopAt,
    recurring: recurring ?? this.recurring,
    daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    syncInterval: syncInterval ?? this.syncInterval,
  );
}
