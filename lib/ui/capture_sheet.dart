import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/queue_provider.dart';

const _appChannel = MethodChannel('com.mindq/app');

class CaptureSheet extends ConsumerStatefulWidget {
  const CaptureSheet({super.key});

  @override
  ConsumerState<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<CaptureSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool quickAdd}) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await ref.read(queueProvider.notifier).add(text);
    if (!mounted) return;
    if (quickAdd && !kIsWeb) {
      Navigator.of(context).pop();
      try {
        await _appChannel.invokeMethod('moveToBackground');
      } catch (_) {}
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New item',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            minLines: 1,
            maxLines: 5,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(quickAdd: false),
            decoration: const InputDecoration(
              hintText: "What's on your mind?",
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, value, __) {
              final enabled = value.text.trim().isNotEmpty;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: enabled ? () => _submit(quickAdd: false) : null,
                        child: const Text('Add'),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
