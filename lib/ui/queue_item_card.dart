import 'package:flutter/material.dart';
import '../models/queue_item.dart';

class QueueItemCard extends StatelessWidget {
  final QueueItem item;
  final double focusFactor;
  final bool focused;
  final VoidCallback onComplete;

  const QueueItemCard({
    super.key,
    required this.item,
    required this.focusFactor,
    required this.focused,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = focused ? 1.0 : 0.82;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: focused
              ? theme.colorScheme.onSurface
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: focused ? 2 : 1,
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
                  Text(
                    item.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize:
                          (theme.textTheme.bodyLarge?.fontSize ?? 16) *
                          textScale,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _relativeTime(item.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize:
                          (theme.textTheme.bodySmall?.fontSize ?? 12) *
                          textScale,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: focused ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !focused,
                child: IconButton(
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  tooltip: 'Mark complete',
                  onPressed: onComplete,
                ),
              ),
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
