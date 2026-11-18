import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Selection is limited to the displayed (filtered) downloads.
class SelectableDownloadList extends StatefulWidget {
  final List<int?> itemIds;
  final Set<int> selectedIds;
  final ValueChanged<Set<int>> onSelectionChanged;
  final IndexedWidgetBuilder itemBuilder;

  const SelectableDownloadList({
    super.key,
    required this.itemIds,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.itemBuilder,
  });

  @override
  State<SelectableDownloadList> createState() => _SelectableDownloadListState();
}

class _SelectableDownloadListState extends State<SelectableDownloadList> {
  final _focusNode = FocusNode();
  final _viewportKey = GlobalKey();
  final _rowKeys = <int, GlobalKey>{};
  Offset? _start;
  Offset? _end;
  Set<int> _baseSelection = {};

  Set<int> get _visibleIds => widget.itemIds.whereType<int>().toSet();

  void _selectAll() => widget.onSelectionChanged(_visibleIds);
  void _clear() => widget.onSelectionChanged({});

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _pointerDown(PointerDownEvent event) {
    _focusNode.requestFocus();
    if (event.kind != PointerDeviceKind.mouse ||
        event.buttons != kPrimaryMouseButton) {
      return;
    }
    final box = _viewportKey.currentContext!.findRenderObject()! as RenderBox;
    _start = box.globalToLocal(event.position);
    final keys = HardwareKeyboard.instance;
    _baseSelection = keys.isControlPressed || keys.isMetaPressed
        ? Set<int>.from(widget.selectedIds)
        : {};
  }

  void _pointerMove(PointerMoveEvent event) {
    if (_start == null) return;
    final box = _viewportKey.currentContext!.findRenderObject()! as RenderBox;
    final end = box.globalToLocal(event.position);
    if (_end == null && (end - _start!).distance < kTouchSlop) return;
    setState(() => _end = end);
    final rect = Rect.fromPoints(_start!, end);
    final ids = Set<int>.from(_baseSelection);
    for (final id in _visibleIds) {
      final row = _rowKeys[id]?.currentContext?.findRenderObject();
      if (row is! RenderBox || !row.attached) continue;
      final origin = box.globalToLocal(row.localToGlobal(Offset.zero));
      if (rect.overlaps(origin & row.size)) ids.add(id);
    }
    widget.onSelectionChanged(ids);
  }

  void _pointerEnd(PointerEvent event) {
    if (_start == null) return;
    setState(() {
      _start = null;
      _end = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleIds;
    _rowKeys.removeWhere((id, _) => !visible.contains(id));
    final count = visible.intersection(widget.selectedIds).length;
    final allSelected = visible.isNotEmpty && count == visible.length;
    final theme = Theme.of(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyA, control: true):
            _selectAll,
        const SingleActivator(LogicalKeyboardKey.keyA, meta: true): _selectAll,
        const SingleActivator(LogicalKeyboardKey.escape): _clear,
      },
      child: Focus(
        focusNode: _focusNode,
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                Checkbox(
                  tristate: true,
                  value: allSelected ? true : (count > 0 ? null : false),
                  onChanged: visible.isEmpty
                      ? null
                      : (_) => allSelected ? _clear() : _selectAll(),
                  semanticLabel: 'Select all downloads',
                ),
                TextButton(
                  onPressed: visible.isEmpty ? null : _selectAll,
                  child: const Text('Select all'),
                ),
                const Spacer(),
                Text('$count selected', style: theme.textTheme.bodySmall),
                TextButton(
                  onPressed: widget.selectedIds.isEmpty ? null : _clear,
                  child: const Text('Clear selection'),
                ),
                const SizedBox(width: 12),
              ],
            ),
            Expanded(
              child: Listener(
                onPointerDown: _pointerDown,
                onPointerMove: _pointerMove,
                onPointerUp: _pointerEnd,
                onPointerCancel: _pointerEnd,
                child: Stack(
                  key: _viewportKey,
                  fit: StackFit.expand,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.itemIds.length,
                      itemBuilder: (context, index) {
                        final id = widget.itemIds[index];
                        return KeyedSubtree(
                          key: id == null
                              ? null
                              : _rowKeys.putIfAbsent(id, GlobalKey.new),
                          child: widget.itemBuilder(context, index),
                        );
                      },
                    ),
                    if (_start != null && _end != null)
                      Positioned.fromRect(
                        rect: Rect.fromPoints(_start!, _end!),
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
