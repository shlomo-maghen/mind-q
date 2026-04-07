import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_settings.dart';

class SettingsRepository {
  static const _enabledKey = 'notif_enabled';
  static const _delayKey = 'notif_delay_minutes';

  Future<NotificationSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDelay = prefs.getInt(_delayKey) ?? 60;
    return NotificationSettings(
      enabled: prefs.getBool(_enabledKey) ?? false,
      delayMinutes: storedDelay > 0 ? storedDelay : 60,
    );
  }

  Future<void> save(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, settings.enabled);
    await prefs.setInt(_delayKey, settings.delayMinutes);
  }
}
