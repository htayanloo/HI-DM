import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/download_queue.dart';
import '../../../data/models/schedule_config.dart';
import '../../../domain/enums/post_action.dart';
import '../../providers/queue_providers.dart';

class QueueEditorDialog extends ConsumerStatefulWidget {
  final DownloadQueue? queue;

  const QueueEditorDialog({super.key, this.queue});

  @override
  ConsumerState<QueueEditorDialog> createState() => _QueueEditorDialogState();
}

class _QueueEditorDialogState extends ConsumerState<QueueEditorDialog> {
  late final TextEditingController _nameController;
  late int _maxConcurrent;
  late PostAction _postAction;
  late final TextEditingController _programController;
  bool _hasSchedule = false;
  TimeOfDay? _startTime;
  TimeOfDay? _stopTime;
  bool _recurring = false;
  final Set<int> _selectedDays = {};

  final _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final q = widget.queue;
    _nameController = TextEditingController(text: q?.name ?? '');
    _maxConcurrent = q?.maxConcurrent ?? 3;
    _postAction = PostAction.values.firstWhere(
      (e) => e.name == q?.postAction,
      orElse: () => PostAction.nothing,
    );
    _programController = TextEditingController(text: q?.postActionProgram ?? '');

    if (q?.schedule != null) {
      _hasSchedule = true;
      final s = q!.schedule!;
      if (s.startAt != null) {
        _startTime = TimeOfDay(hour: s.startAt!.hour, minute: s.startAt!.minute);
      }
      if (s.stopAt != null) {
        _stopTime = TimeOfDay(hour: s.stopAt!.hour, minute: s.stopAt!.minute);
      }
      _recurring = s.recurring;
      _selectedDays.addAll(s.daysOfWeek);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _programController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;

    ScheduleConfig? schedule;
    if (_hasSchedule) {
      final now = DateTime.now();
      schedule = ScheduleConfig(
        startAt: _startTime != null
            ? DateTime(now.year, now.month, now.day, _startTime!.hour, _startTime!.minute)
            : null,
        stopAt: _stopTime != null
            ? DateTime(now.year, now.month, now.day, _stopTime!.hour, _stopTime!.minute)
            : null,
        recurring: _recurring,
        daysOfWeek: _selectedDays.toList()..sort(),
      );
    }

    final queue = DownloadQueue(
      id: widget.queue?.id,
      name: _nameController.text.trim(),
      maxConcurrent: _maxConcurrent,
      schedule: schedule,
      postAction: _postAction.name,
      postActionProgram: _postAction == PostAction.runProgram ? _programController.text : null,
      isActive: widget.queue?.isActive ?? false,
    );

    final repo = ref.read(queueRepositoryProvider);
    if (widget.queue != null) {
      await repo.updateQueue(queue);
    } else {
      await repo.insertQueue(queue);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.queue != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'Edit Queue' : 'Create Queue',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Queue Name'),
                ),
                const SizedBox(height: 16),

                Text('Max simultaneous downloads: $_maxConcurrent'),
                Slider(
                  value: _maxConcurrent.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '$_maxConcurrent',
                  onChanged: (v) => setState(() => _maxConcurrent = v.round()),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<PostAction>(
                  initialValue: _postAction,
                  decoration: const InputDecoration(labelText: 'Post-completion action', isDense: true),
                  items: PostAction.values
                      .map((a) => DropdownMenuItem(value: a, child: Text(a.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _postAction = v ?? PostAction.nothing),
                ),

                if (_postAction == PostAction.runProgram) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _programController,
                    decoration: const InputDecoration(
                      labelText: 'Program path',
                      hintText: '/path/to/program',
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(),

                SwitchListTile(
                  title: const Text('Schedule'),
                  value: _hasSchedule,
                  onChanged: (v) => setState(() => _hasSchedule = v),
                  contentPadding: EdgeInsets.zero,
                ),

                if (_hasSchedule) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Start Time', style: TextStyle(fontSize: 13)),
                          subtitle: Text(
                            _startTime != null ? _startTime!.format(context) : 'Not set',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _startTime ?? TimeOfDay.now(),
                            );
                            if (time != null) setState(() => _startTime = time);
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('Stop Time', style: TextStyle(fontSize: 13)),
                          subtitle: Text(
                            _stopTime != null ? _stopTime!.format(context) : 'Not set',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _stopTime ?? TimeOfDay.now(),
                            );
                            if (time != null) setState(() => _stopTime = time);
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),

                  CheckboxListTile(
                    title: const Text('Recurring', style: TextStyle(fontSize: 13)),
                    value: _recurring,
                    onChanged: (v) => setState(() => _recurring = v ?? false),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  if (_recurring)
                    Wrap(
                      spacing: 4,
                      children: List.generate(7, (i) {
                        final day = i + 1;
                        return FilterChip(
                          label: Text(_dayNames[i], style: const TextStyle(fontSize: 11)),
                          selected: _selectedDays.contains(day),
                          onSelected: (sel) {
                            setState(() {
                              if (sel) {
                                _selectedDays.add(day);
                              } else {
                                _selectedDays.remove(day);
                              }
                            });
                          },
                          visualDensity: VisualDensity.compact,
                        );
                      }),
                    ),
                ],

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _save,
                      child: Text(isEditing ? 'Save' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
