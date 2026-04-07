import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';
import '../services/settings_repository.dart';

final _repo = SettingsRepository();

class SettingsNotifier extends AsyncNotifier<NotificationSettings> {
  @override
  Future<NotificationSettings> build() => _repo.load();

  Future<void> setEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const NotificationSettings();
    final updated = NotificationSettings(
      enabled: enabled,
      delayMinutes: current.delayMinutes,
    );
    state = AsyncData(updated);
    await _repo.save(updated);
    if (!enabled && !kIsWeb) {
      await NotificationService.instance.cancel();
    }
  }

  Future<void> setDelay(int minutes) async {
    final current = state.valueOrNull ?? const NotificationSettings();
    final updated = NotificationSettings(
      enabled: current.enabled,
      delayMinutes: minutes,
    );
    state = AsyncData(updated);
    await _repo.save(updated);
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, NotificationSettings>(
        SettingsNotifier.new);
