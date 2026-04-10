import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_q/models/notification_settings.dart';
import 'package:mind_q/providers/settings_provider.dart';
import 'package:mind_q/ui/settings_view.dart';

// ---------------------------------------------------------------------------
// Fake notifier
// ---------------------------------------------------------------------------
class FakeSettingsNotifier extends AsyncNotifier<NotificationSettings>
    implements SettingsNotifier {
  FakeSettingsNotifier(this._settings);
  final NotificationSettings _settings;
  final enabledCalls = <bool>[];
  final delayCalls = <int>[];

  @override
  Future<NotificationSettings> build() async => _settings;

  @override
  Future<void> setEnabled(bool enabled) async {
    enabledCalls.add(enabled);
    state = AsyncData(NotificationSettings(
      enabled: enabled,
      delayMinutes: state.valueOrNull?.delayMinutes ?? 60,
    ));
  }

  @override
  Future<void> setDelay(int minutes) async {
    delayCalls.add(minutes);
    state = AsyncData(NotificationSettings(
      enabled: state.valueOrNull?.enabled ?? false,
      delayMinutes: minutes,
    ));
  }
}

Widget buildSubject(NotificationSettings settings, {FakeSettingsNotifier? captureNotifier}) {
  final notifier = captureNotifier ?? FakeSettingsNotifier(settings);
  return ProviderScope(
    overrides: [
      settingsProvider.overrideWith(() => notifier),
    ],
    child: const MaterialApp(home: SettingsView()),
  );
}

void main() {
  testWidgets('shows switch tile reflecting enabled=false', (tester) async {
    await tester.pumpWidget(buildSubject(const NotificationSettings()));
    await tester.pump();
    final switchTile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(switchTile.value, isFalse);
  });

  testWidgets('shows switch tile reflecting enabled=true', (tester) async {
    await tester.pumpWidget(
      buildSubject(const NotificationSettings(enabled: true, delayMinutes: 90)),
    );
    await tester.pump();
    final switchTile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(switchTile.value, isTrue);
  });

  testWidgets('delay field shows current delayMinutes value', (tester) async {
    await tester.pumpWidget(
      buildSubject(const NotificationSettings(enabled: true, delayMinutes: 120)),
    );
    await tester.pump();
    expect(find.text('120'), findsOneWidget);
  });

  testWidgets('delay field is disabled when notifications are off', (tester) async {
    await tester.pumpWidget(buildSubject(const NotificationSettings(enabled: false)));
    await tester.pump();
    // Find the delay TextField (not the one in AppBar etc.)
    final textFields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    // The delay field is the only TextField on this screen
    expect(textFields.any((tf) => tf.enabled == false), isTrue);
  });

  testWidgets('toggling switch ON calls setEnabled(true)', (tester) async {
    final notifier = FakeSettingsNotifier(const NotificationSettings(enabled: false));
    await tester.pumpWidget(buildSubject(const NotificationSettings(), captureNotifier: notifier));
    await tester.pump();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(notifier.enabledCalls, [true]);
  });

  testWidgets('toggling switch OFF calls setEnabled(false)', (tester) async {
    final notifier = FakeSettingsNotifier(const NotificationSettings(enabled: true));
    await tester.pumpWidget(
      buildSubject(const NotificationSettings(enabled: true), captureNotifier: notifier),
    );
    await tester.pump();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(notifier.enabledCalls, [false]);
  });

  testWidgets('submitting valid delay calls setDelay', (tester) async {
    final notifier = FakeSettingsNotifier(const NotificationSettings(enabled: true, delayMinutes: 60));
    await tester.pumpWidget(
      buildSubject(const NotificationSettings(enabled: true), captureNotifier: notifier),
    );
    await tester.pump();
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '90');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(notifier.delayCalls, [90]);
  });

  testWidgets('submitting invalid delay reverts field to current value', (tester) async {
    final notifier = FakeSettingsNotifier(const NotificationSettings(enabled: true, delayMinutes: 60));
    await tester.pumpWidget(
      buildSubject(const NotificationSettings(enabled: true, delayMinutes: 60), captureNotifier: notifier),
    );
    await tester.pump();
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(notifier.delayCalls, isEmpty);
    expect(find.text('60'), findsOneWidget);
  });
}
