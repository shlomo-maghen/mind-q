import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _notifId = 13232323;
  static const _channelId = 'mind_q_reminders';
  static const _channelName = 'Queue Reminders';

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin, macOS: darwin),
    );
  }

  Future<void> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
        return;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        await ios.requestPermissions(alert: true, badge: true, sound: false);
      }
    } catch (_) {}
  }

  Future<void> schedule(int count, int delayMinutes) async {
    await cancel();
    final now = tz.TZDateTime.now(tz.UTC);
    final scheduledTime = now.add(Duration(minutes: delayMinutes));
    final body =
        'You have $count thing${count == 1 ? '' : 's'} in your queue.';

    await _plugin
        .zonedSchedule(
          _notifId,
          'Mind-Q',
          body,
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
  }

  Future<void> cancel() async {
    try {
      await _plugin.cancel(_notifId);
    } catch (_) {}
  }
}
