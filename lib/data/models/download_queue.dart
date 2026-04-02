import 'schedule_config.dart';

class DownloadQueue {
  final int? id;
  final String name;
  final int maxConcurrent;
  final ScheduleConfig? schedule;
  final String postAction; // from PostAction enum name
  final String? postActionProgram;
  final bool isActive;

  const DownloadQueue({
    this.id,
    required this.name,
    this.maxConcurrent = 3,
    this.schedule,
    this.postAction = 'nothing',
    this.postActionProgram,
    this.isActive = false,
  });

  DownloadQueue copyWith({
    int? id,
    String? name,
    int? maxConcurrent,
    ScheduleConfig? schedule,
    String? postAction,
    String? postActionProgram,
    bool? isActive,
  }) => DownloadQueue(
    id: id ?? this.id,
    name: name ?? this.name,
    maxConcurrent: maxConcurrent ?? this.maxConcurrent,
    schedule: schedule ?? this.schedule,
    postAction: postAction ?? this.postAction,
    postActionProgram: postActionProgram ?? this.postActionProgram,
    isActive: isActive ?? this.isActive,
  );
}
