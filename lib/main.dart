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

class _MindQAppState extends ConsumerState<MindQApp>
    with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;
    if (state == AppLifecycleState.paused) {
      _maybeScheduleNotification();
    } else if (state == AppLifecycleState.resumed) {
      NotificationService.instance.cancel();
    }
  }

  Future<void> _maybeScheduleNotification() async {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings == null || !settings.enabled) return;
    final queue = ref.read(queueProvider).valueOrNull;
    if (queue == null || queue.isEmpty) return;
    await NotificationService.instance.schedule(queue.length, settings.delayMinutes);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mind-Q',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEE616E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEE616E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
