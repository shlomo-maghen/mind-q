import 'package:flutter_test/flutter_test.dart';
import 'package:mind_q/models/notification_settings.dart';

void main() {
  group('NotificationSettings', () {
    test('defaults: enabled=false, delayMinutes=60', () {
      const settings = NotificationSettings();
      expect(settings.enabled, isFalse);
      expect(settings.delayMinutes, 60);
    });

    test('explicit values are preserved', () {
      const settings = NotificationSettings(enabled: true, delayMinutes: 120);
      expect(settings.enabled, isTrue);
      expect(settings.delayMinutes, 120);
    });

    test('model itself does not enforce minimum delay (that is the repository job)', () {
      // The model stores whatever value is given — SettingsRepository enforces the min.
      const settings = NotificationSettings(enabled: true, delayMinutes: 0);
      expect(settings.delayMinutes, 0);
    });
  });
}
