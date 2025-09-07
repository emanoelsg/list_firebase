import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
import 'package:list_firebase/app/features/notifications/service/notifications_service.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';

// Mock do serviço de notificações
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late NotificationController controller;
  late MockNotificationService mockService;

  // Criando uma TaskEntity personalizada para testes
  TaskEntity createTask({bool withReminder = true}) {
    return TaskEntity(
      id: 'task123',
      title: 'Test Task',
      userId: 'user1',
      createdAt: DateTime.now(),
      reminderAt: withReminder ? DateTime.now().add(const Duration(minutes: 5)) : null,
      repeatType: 'daily',
      reminderTime: '08:30',
    );
  }

  setUp(() {
    mockService = MockNotificationService();
    controller = NotificationController(service: mockService);
  });

  test('scheduleReminderForTask chama scheduleTaskNotification', () async {
    final task = createTask();

    when(() => mockService.scheduleTaskNotification(task))
        .thenAnswer((_) async {});

    await controller.scheduleReminderForTask(task);

    verify(() => mockService.scheduleTaskNotification(task)).called(1);
  });

  test('cancelReminder chama cancelNotification com o id correto', () async {
    const id = 42;

    when(() => mockService.cancelNotification(id)).thenAnswer((_) async {});

    await controller.cancelReminder(id);

    verify(() => mockService.cancelNotification(id)).called(1);
  });

  test('cancelRemindersForTask chama cancelAllForTask', () async {
    final task = createTask();

    when(() => mockService.cancelAllForTask(task)).thenAnswer((_) async {});

    await controller.cancelRemindersForTask(task);

    verify(() => mockService.cancelAllForTask(task)).called(1);
  });

  test(
      'scheduleReminderForTask não lança erro se reminderAt e reminderTime forem nulos',
      () async {
    final task = createTask(withReminder: false);

    when(() => mockService.scheduleTaskNotification(task))
        .thenAnswer((_) async {});

    await controller.scheduleReminderForTask(task);

    verify(() => mockService.scheduleTaskNotification(task)).called(1);
  });
}
