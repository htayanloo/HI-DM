import 'dart:async';

import '../../data/repositories/queue_repository.dart';

class SchedulerService {
  final QueueRepository _queueRepo;
  Timer? _timer;
  final void Function(int queueId, bool shouldStart) onQueueAction;

  SchedulerService({
    required QueueRepository queueRepo,
    required this.onQueueAction,
  }) : _queueRepo = queueRepo;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _check());
    _check();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _check() async {
    final queues = await _queueRepo.getAllQueues();
    final now = DateTime.now();

    for (final queue in queues) {
      if (queue.schedule == null) continue;
      final schedule = queue.schedule!;

      // Check day-of-week filter
      if (schedule.daysOfWeek.isNotEmpty) {
        if (!schedule.daysOfWeek.contains(now.weekday)) continue;
      }

      // Check start time
      if (schedule.startAt != null && !queue.isActive) {
        if (_isTimeToStart(schedule.startAt!, now)) {
          onQueueAction(queue.id!, true);
          await _queueRepo.setQueueActive(queue.id!, true);
        }
      }

      // Check stop time
      if (schedule.stopAt != null && queue.isActive) {
        if (_isTimePassed(schedule.stopAt!, now)) {
          onQueueAction(queue.id!, false);
          await _queueRepo.setQueueActive(queue.id!, false);
        }
      }
    }
  }

  bool _isTimeToStart(DateTime scheduledTime, DateTime now) {
    return now.hour == scheduledTime.hour &&
        now.minute == scheduledTime.minute &&
        (now.second < 30); // within the check window
  }

  bool _isTimePassed(DateTime scheduledTime, DateTime now) {
    final scheduledMinutes = scheduledTime.hour * 60 + scheduledTime.minute;
    final nowMinutes = now.hour * 60 + now.minute;
    return nowMinutes >= scheduledMinutes;
  }

  void dispose() {
    stop();
  }
}
