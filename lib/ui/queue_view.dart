import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/queue_provider.dart';
import 'empty_state.dart';
import 'queue_item_card.dart';

const _appChannel = MethodChannel('com.lismodev.mindqueue/app');

class QueueView extends ConsumerStatefulWidget {
  const QueueView({super.key});

  @override
  ConsumerState<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends ConsumerState<QueueView> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool quickAdd}) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    await ref.read(queueProvider.notifier).add(text);
    if (!mounted) return;
    _textController.clear();
    if (quickAdd && !kIsWeb) {
      try {
        await _appChannel.invokeMethod('moveToBackground');
      } catch (_) {}
    }
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all items?'),
        content: const Text('This will remove all items from your queue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(queueProvider.notifier).clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueState = ref.watch(queueProvider);
    final isFocused = _focusNode.hasFocus;
    final hasItems = queueState.valueOrNull?.isNotEmpty ?? false;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('MindQueue'),
        centerTitle: false,
        actions: [
          if (hasItems)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Clear all',
              onPressed: _confirmClearAll,
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedOpacity(
            opacity: isFocused ? 1.0 : 0.38,
            duration: const Duration(milliseconds: 200),
            child: _buildCaptureArea(),
          ),
          Expanded(
            child: Stack(
              children: [
                queueState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (items) => items.isEmpty
                      ? const EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 560),
                                child: QueueItemCard(
                                  key: ValueKey(item.id),
                                  item: item,
                                  onComplete: () => ref
                                      .read(queueProvider.notifier)
                                      .remove(item.id),
                                  onEdit: (text) => ref
                                      .read(queueProvider.notifier)
                                      .edit(item.id, text),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (isFocused)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _focusNode.unfocus,
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                if (isFocused)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    child: SafeArea(
                      top: false,
                      child: _buildActionButtons(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        minLines: 1,
        maxLines: 5,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(quickAdd: false),
        decoration: const InputDecoration(
          hintText: 'Tap to add...',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: ValueListenableBuilder(
        valueListenable: _textController,
        builder: (_, value, __) {
          final enabled = value.text.trim().isNotEmpty;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: enabled ? () => _submit(quickAdd: true) : null,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Quick Add'),
                        SizedBox(height: 2),
                        Text(
                          'add and leave',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: enabled ? () => _submit(quickAdd: false) : null,
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
