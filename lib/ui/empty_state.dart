import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 56, color: color),
          const SizedBox(height: 16),
          Text(
            'Queue is clear. You\'re focused.',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
