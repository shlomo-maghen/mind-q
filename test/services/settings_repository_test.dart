import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_q/models/notification_settings.dart';
import 'package:mind_q/services/settings_repository.dart';

void main() {
  group('SettingsRepository', () {
    late SettingsRepository repo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repo = SettingsRepository();
    });

    test('load returns defaults when nothing stored', () async {
      final settings = await repo.load();
      expect(settings.enabled, isFalse);
      expect(settings.delayMinutes, 60);
    });

    test('save then load round-trips enabled=true and delayMinutes=120', () async {
      await repo.save(const NotificationSettings(enabled: true, delayMinutes: 120));
      final settings = await repo.load();
      expect(settings.enabled, isTrue);
      expect(settings.delayMinutes, 120);
    });

    test('save then load round-trips enabled=false', () async {
      await repo.save(const NotificationSettings(enabled: false, delayMinutes: 90));
      final settings = await repo.load();
      expect(settings.enabled, isFalse);
    });

    test('load enforces minimum 60 minutes when stored value is 0', () async {
      SharedPreferences.setMockInitialValues({
        'notif_enabled': true,
        'notif_delay_minutes': 0,
      });
      final settings = await repo.load();
      expect(settings.delayMinutes, 60);
    });

    test('load enforces minimum 60 minutes when stored value is negative', () async {
      SharedPreferences.setMockInitialValues({
        'notif_enabled': true,
        'notif_delay_minutes': -10,
      });
      final settings = await repo.load();
      expect(settings.delayMinutes, 60);
    });

    test('load passes through values above 60 unchanged', () async {
      await repo.save(const NotificationSettings(enabled: true, delayMinutes: 90));
      final settings = await repo.load();
      expect(settings.delayMinutes, 90);
    });

    test('enabled and delayMinutes are persisted independently', () async {
      await repo.save(const NotificationSettings(enabled: true, delayMinutes: 200));
      await repo.save(const NotificationSettings(enabled: false, delayMinutes: 90));
      final settings = await repo.load();
      expect(settings.enabled, isFalse);
      expect(settings.delayMinutes, 90);
    });
  });
}
