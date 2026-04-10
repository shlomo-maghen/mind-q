import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_q/providers/settings_provider.dart';

void main() {
  group('SettingsNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      await container.read(settingsProvider.future);
    });

    tearDown(() => container.dispose());

    test('initial state: enabled=false, delayMinutes=60', () {
      final settings = container.read(settingsProvider).valueOrNull!;
      expect(settings.enabled, isFalse);
      expect(settings.delayMinutes, 60);
    });

    test('setEnabled(true) updates state', () async {
      await container.read(settingsProvider.notifier).setEnabled(true);
      expect(container.read(settingsProvider).valueOrNull!.enabled, isTrue);
    });

    test('setEnabled(false) updates state without throwing', () async {
      await container.read(settingsProvider.notifier).setEnabled(true);
      await container.read(settingsProvider.notifier).setEnabled(false);
      expect(container.read(settingsProvider).valueOrNull!.enabled, isFalse);
    });

    test('setDelay(120) updates delayMinutes', () async {
      await container.read(settingsProvider.notifier).setDelay(120);
      expect(container.read(settingsProvider).valueOrNull!.delayMinutes, 120);
    });

    test('setDelay preserves current enabled value', () async {
      await container.read(settingsProvider.notifier).setEnabled(true);
      await container.read(settingsProvider.notifier).setDelay(90);
      final settings = container.read(settingsProvider).valueOrNull!;
      expect(settings.enabled, isTrue);
      expect(settings.delayMinutes, 90);
    });

    test('setEnabled persists across container restart', () async {
      await container.read(settingsProvider.notifier).setEnabled(true);
      container.dispose();

      final container2 = ProviderContainer();
      addTearDown(container2.dispose);
      await container2.read(settingsProvider.future);
      expect(container2.read(settingsProvider).valueOrNull!.enabled, isTrue);
    });

    test('setDelay persists across container restart', () async {
      await container.read(settingsProvider.notifier).setDelay(150);
      container.dispose();

      final container2 = ProviderContainer();
      addTearDown(container2.dispose);
      await container2.read(settingsProvider.future);
      expect(container2.read(settingsProvider).valueOrNull!.delayMinutes, 150);
    });
  });
}
