import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/queue_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'ui/queue_view.dart';
import 'ui/settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await NotificationService.instance.init();
  }
  runApp(const ProviderScope(child: MindQApp()));
}

class MindQApp extends ConsumerStatefulWidget {
  const MindQApp({super.key});

  @override
  ConsumerState<MindQApp> createState() => _MindQAppState();
}

class _MindQAppState extends ConsumerState<MindQApp> {
  static const _rescheduleInterval = Duration(seconds: 10);

  late final GoRouter _router;
  late final AppLifecycleListener _lifecycleListener;
  Timer? _rescheduleTimer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onHide: _onHide,
      onShow: _onShow,
    );
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const QueueView(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsView(),
        ),
      ],
    );
  }

  /// Sets (or cancels) the reminder alarm based on current queue/settings.
  /// Called repeatedly by [_updateRescheduler] to keep the alarm's fire time
  /// sliding forward while the user is in the app, and once on [_onHide] to
  /// lock in the final fire time relative to when the user left.
  Future<void> _scheduleOnce() async {
    if (kIsWeb) return;
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings == null || !settings.enabled) return;
    final queue = ref.read(queueProvider).valueOrNull;
    if (queue == null || queue.isEmpty) {
      await NotificationService.instance.cancel();
      return;
    }
    await NotificationService.instance
        .schedule(queue.length, settings.delayMinutes);
  }

  /// Starts/stops the rolling reschedule loop based on current visibility +
  /// queue + settings. While running, the alarm is reset every
  /// [_rescheduleInterval] to `now + delayMinutes`, which means:
  ///   1. It never fires while the user is in the app (target keeps moving).
  ///   2. If the OS kills the process (swipe-away) before [_onHide] completes,
  ///      the most recent alarm is still registered with AlarmManager and will
  ///      fire at most [_rescheduleInterval] earlier than intended.
  void _updateRescheduler() {
    if (kIsWeb) return;
    _rescheduleTimer?.cancel();
    _rescheduleTimer = null;
    if (!_isVisible) return;
    final settings = ref.read(settingsProvider).valueOrNull;
    final queue = ref.read(queueProvider).valueOrNull;
    final shouldSchedule = settings != null &&
        settings.enabled &&
        queue != null &&
        queue.isNotEmpty;
    if (!shouldSchedule) {
      NotificationService.instance.cancel();
      return;
    }
    _scheduleOnce();
    _rescheduleTimer =
        Timer.periodic(_rescheduleInterval, (_) => _scheduleOnce());
  }

  Future<void> _onHide() async {
    _isVisible = false;
    _rescheduleTimer?.cancel();
    _rescheduleTimer = null;
    await _scheduleOnce();
  }

  void _onShow() {
    _isVisible = true;
    if (kIsWeb) return;
    NotificationService.instance.cancel();
    _updateRescheduler();
  }

  @override
  void dispose() {
    _rescheduleTimer?.cancel();
    _lifecycleListener.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(queueProvider, (_, __) => _updateRescheduler());
    ref.listen(settingsProvider, (_, __) => _updateRescheduler());

    return MaterialApp.router(
      title: 'MindQueue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 17, 145, 47),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 17, 145, 47),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
