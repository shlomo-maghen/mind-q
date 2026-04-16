import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  late final TextEditingController _delayController;
  bool _initialized = false;

  @override
  void dispose() {
    _delayController.dispose();
    super.dispose();
  }

  void _commitDelay() {
    final value = int.tryParse(_delayController.text);
    if (value != null && value > 0) {
      ref.read(settingsProvider.notifier).setDelay(value);
    } else {
      // Revert to current saved value on invalid input
      final current = ref.read(settingsProvider).valueOrNull;
      if (current != null) {
        _delayController.text = current.delayMinutes.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: settingsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) {
          // Initialize controller once from persisted value
          if (!_initialized) {
            _delayController =
                TextEditingController(text: settings.delayMinutes.toString());
            _initialized = true;
          }

          return ListView(
            children: [
              if (kIsWeb) ...[
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Notifications are not supported on web.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ] else ...[
                SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Remind me when items are waiting'),
                  value: settings.enabled,
                  onChanged: (value) async {
                    if (value) {
                      await NotificationService.instance.requestPermission();
                    }
                    await ref
                        .read(settingsProvider.notifier)
                        .setEnabled(value);
                  },
                ),
                const Divider(height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Remind me after',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: settings.enabled
                                    ? null
                                    : Theme.of(context).disabledColor,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 72,
                        child: TextField(
                          controller: _delayController,
                          enabled: settings.enabled,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _commitDelay(),
                          onTapOutside: (_) => _commitDelay(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'minutes',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: settings.enabled
                                    ? null
                                    : Theme.of(context).disabledColor,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
