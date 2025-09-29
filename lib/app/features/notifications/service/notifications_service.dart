// app/features/notifications/service/notifications_service.dart
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:list_firebase/app/features/notifications/utils/notification_helper.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();


  Future<void> init() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }
  Future<void> _requestExactAlarmPermissionIfNeeded() async {
    if (!Platform.isAndroid) return;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdk = androidInfo.version.sdkInt;
      if (sdk >= 31) {
        // Android 12+
        final intent = const AndroidIntent(
          action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        );
        await intent.launch();
      }
    } catch (e, st) {
      debugPrint('Erro ao solicitar permissão de alarmes exatos: $e\n$st');
    }
  }

  Future<void> scheduleTaskNotification(TaskEntity task) async {
    if (task.reminderAt == null && task.reminderTime == null) return;
    await _requestExactAlarmPermissionIfNeeded();

    final androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Tarefas',
      channelDescription: 'Lembretes de tarefas',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);

    // 🔹 Notificação única
    if (task.reminderAt != null) {
      await _plugin.zonedSchedule(
        NotificationHelper.baseId(task),
        'Lembrete de tarefa',
        task.title,
        tz.TZDateTime.from(task.reminderAt!, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    // 🔹 Notificação recorrente (diária ou semanal)
    if ((task.repeatType == 'daily' || task.repeatType == 'weekly') &&
        task.reminderTime != null) {
      final parts = task.reminderTime!.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (task.repeatType == 'daily') {
        await _plugin.zonedSchedule(
          NotificationHelper.baseId(task),
          'Lembrete de tarefa',
          task.title,
          _nextInstanceOfTime(hour, minute),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else if (task.weekDays != null && task.weekDays!.isNotEmpty) {
        for (final wd in task.weekDays!) {
          await _plugin.zonedSchedule(
            NotificationHelper.weeklyId(task, wd),
            'Lembrete de tarefa',
            task.title,
            _nextInstanceOfWeekdayTime(wd, hour, minute),
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
    }
  }

  Future<void> cancelNotification(int id) async => _plugin.cancel(id);

  Future<void> cancelAllForTask(TaskEntity task) async {
    await cancelNotification(NotificationHelper.baseId(task));
    if (task.weekDays != null) {
      for (var wd in task.weekDays!) {
        await cancelNotification(NotificationHelper.weeklyId(task, wd));
      }
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    var scheduled = _nextInstanceOfTime(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return scheduled;
  }
}
