import 'package:flutter/material.dart';
import '../models/queue_item.dart';

class QueueItemCard extends StatefulWidget {
  final QueueItem item;
  final VoidCallback onComplete;
  final void Function(String newText) onEdit;

  const QueueItemCard({
    super.key,
    required this.item,
    required this.onComplete,
    required this.onEdit,
  });

  @override
  State<QueueItemCard> createState() => _QueueItemCardState();
}

class _QueueItemCardState extends State<QueueItemCard> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.text);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(QueueItemCard old) {
    super.didUpdateWidget(old);
    if (!_editing && old.item.text != widget.item.text) {
      _controller.text = widget.item.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _editing) {
      _commit();
    }
  }

  void _startEditing() {
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _commit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && text != widget.item.text) {
      widget.onEdit(text);
    } else {
      _controller.text = widget.item.text;
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _editing
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: _editing ? 2 : 1,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_editing)
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: theme.textTheme.bodyLarge,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _commit(),
                      onTapOutside: (_) => _focusNode.unfocus(),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _startEditing,
                      child: Text(
                        widget.item.text,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _relativeTime(widget.item.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline_rounded),
              tooltip: 'Mark complete',
              onPressed: widget.onComplete,
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays}d ago';
  }
}
