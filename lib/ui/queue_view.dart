import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/queue_item.dart';
import '../providers/queue_provider.dart';
import 'empty_state.dart';
import 'queue_item_card.dart';

const _appChannel = MethodChannel('com.mindq/app');

class QueueView extends ConsumerStatefulWidget {
  const QueueView({super.key});

  @override
  ConsumerState<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends ConsumerState<QueueView> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSnapping = false;

  // Must match the visual height of QueueItemCard (card + margins).
  static const double _itemExtent = 96.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _focusNode.addListener(_onFocusChange);
  }

  void _onScroll() => setState(() {});
  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
    _focusNode.unfocus();
    if (quickAdd && !kIsWeb) {
      try {
        await _appChannel.invokeMethod('moveToBackground');
      } catch (_) {}
    }
  }

  void _snapToNearest(int itemCount) {
    if (!_scrollController.hasClients || _isSnapping) return;
    final offset = _scrollController.offset;
    final targetIndex = (offset / _itemExtent).round().clamp(0, itemCount - 1);
    final targetOffset = targetIndex * _itemExtent;
    if ((offset - targetOffset).abs() > 0.5) {
      _isSnapping = true;
      _scrollController
          .animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() => _isSnapping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueState = ref.watch(queueProvider);
    final isFocused = _focusNode.hasFocus;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Mind-Q'),
        centerTitle: false,
        actions: [
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
                  data: (items) =>
                      items.isEmpty ? const EmptyState() : _buildList(items),
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
                    child: _buildActionButtons(),
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

  Widget _buildList(List<QueueItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final anchorY = constraints.maxHeight * 0.25;
        final topPadding = anchorY - _itemExtent / 2;
        final bottomPadding = constraints.maxHeight - anchorY - _itemExtent / 2;
        final scrollOffset =
            _scrollController.hasClients ? _scrollController.offset : 0.0;
        const fadeRange = _itemExtent * 2.0;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (_) {
                _snapToNearest(items.length);
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: items.length,
                padding:
                    EdgeInsets.only(top: topPadding, bottom: bottomPadding),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selectedIndex = (scrollOffset / _itemExtent)
                      .round()
                      .clamp(0, items.length - 1);
                  final focused = index == selectedIndex;
                  final itemCenter = topPadding +
                      index * _itemExtent +
                      _itemExtent / 2 -
                      scrollOffset;
                  final distanceFromCenter = (itemCenter - anchorY).abs();
                  final focusFactor =
                      (1.0 - distanceFromCenter / fadeRange).clamp(0.0, 1.0);
                  final opacity = 0.28 + 0.72 * focusFactor;
                  final extraPad = (1.0 - focusFactor) * 24.0;

                  return SizedBox(
                    height: _itemExtent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: extraPad),
                      child: Opacity(
                        opacity: opacity,
                        child: QueueItemCard(
                          key: ValueKey(item.id),
                          item: item,
                          focusFactor: focusFactor,
                          focused: focused,
                          onComplete: () =>
                              ref.read(queueProvider.notifier).remove(item.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
