import 'package:flutter_test/flutter_test.dart';
import 'package:list_firebase/app/features/notifications/service/notifications_service.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:list_firebase/app/features/notifications/utils/notification_helper.dart';

// Mock do plugin
class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

// Fakes necessários para Mocktail
class FakeInitializationSettings extends Fake implements InitializationSettings {}
class FakeNotificationDetails extends Fake implements NotificationDetails {}
class FakeTZDateTime extends Fake implements tz.TZDateTime {}

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late NotificationService service;

  // Registrar fallback values antes de usar any() em named arguments
  setUpAll(() {
    registerFallbackValue(FakeInitializationSettings());
    registerFallbackValue(FakeNotificationDetails());
    registerFallbackValue(FakeTZDateTime());
  });

  setUp(() {
    tz.initializeTimeZones();
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    service = NotificationService(plugin: mockPlugin);

    // Inicialização do plugin
    when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);

    // mock do zonedSchedule
    when(() => mockPlugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        )).thenAnswer((_) async => {});

    // mock do cancel
    when(() => mockPlugin.cancel(any())).thenAnswer((_) async => {});
  });

  test('Não agenda nada se reminderAt e reminderTime forem nulos', () async {
    final task = TaskEntity(
      id: '1',
      title: 'Test Task',
      userId: 'user123',
      createdAt: DateTime.now(),
    );

    await service.scheduleTaskNotification(task);

    verifyNever(() => mockPlugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        ));
  });

  test('Agenda notificação única quando reminderAt está definido', () async {
    final task = TaskEntity(
      id: '2',
      title: 'Test Task 2',
      userId: 'user123',
      createdAt: DateTime.now(),
      reminderAt: DateTime.now().add(const Duration(minutes: 5)),
    );

    await service.scheduleTaskNotification(task);

    verify(() => mockPlugin.zonedSchedule(
          any(),
          'Lembrete de tarefa',
          'Test Task 2',
          any(),
          any(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        )).called(1);
  });

  test('Cancela base e notificações semanais', () async {
    final task = TaskEntity(
      id: '3',
      title: 'Task 3',
      userId: 'user123',
      createdAt: DateTime.now(),
      weekDays: [1, 3],
    );

    await service.cancelAllForTask(task);

    // base + 2 weekDays
    verify(() => mockPlugin.cancel(any())).called(3);
  });
  test('Init inicializa plugin corretamente', () async {
  when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);

  await service.init();

  verify(() => mockPlugin.initialize(any())).called(1);
});

test('Agenda notificação diária quando repeatType = daily', () async {
  final task = TaskEntity(
    id: '4',
    title: 'Task Daily',
    userId: 'user123',
    createdAt: DateTime.now(),
    reminderTime: '08:30',
    repeatType: 'daily',
  );

  await service.scheduleTaskNotification(task);

  verify(() => mockPlugin.zonedSchedule(
        any(),
        'Lembrete de tarefa',
        'Task Daily',
        any(),
        any(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      )).called(1);
});

test('Agenda notificações semanais quando repeatType = weekly', () async {
  final task = TaskEntity(
    id: '5',
    title: 'Task Weekly',
    userId: 'user123',
    createdAt: DateTime.now(),
    reminderTime: '10:00',
    repeatType: 'weekly',
    weekDays: [1, 5], // segunda e sexta
  );

  await service.scheduleTaskNotification(task);

  verify(() => mockPlugin.zonedSchedule(
        any(),
        'Lembrete de tarefa',
        'Task Weekly',
        any(),
        any(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      )).called(2); // uma por cada dia da lista
});

test('CancelNotification cancela exatamente um id', () async {
  await service.cancelNotification(42);

  verify(() => mockPlugin.cancel(42)).called(1);
});

test('Agenda notificações semanais corretamente', () async {
  final task = TaskEntity(
    id: '4',
    title: 'Weekly Task',
    userId: 'user123',
    createdAt: DateTime.now(),
    reminderTime: '10:00',
    repeatType: 'weekly',
    weekDays: [DateTime.monday, DateTime.wednesday],
  );

  await service.scheduleTaskNotification(task);

  // Deve agendar 2 notificações (segunda e quarta)
  verify(() => mockPlugin.zonedSchedule(
    NotificationHelper.weeklyId(task, DateTime.monday),
    'Lembrete de tarefa',
    'Weekly Task',
    any(),
    any(),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
  )).called(1);

  verify(() => mockPlugin.zonedSchedule(
    NotificationHelper.weeklyId(task, DateTime.wednesday),
    'Lembrete de tarefa',
    'Weekly Task',
    any(),
    any(),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
  )).called(1);
});


}
