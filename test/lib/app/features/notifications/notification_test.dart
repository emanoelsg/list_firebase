// test/lib/app/features/notifications/notification_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
import 'package:list_firebase/app/features/notifications/service/notifications_service.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late NotificationController controller;
  late MockNotificationService mockService;

  setUp(() {
    mockService = MockNotificationService();
    controller = NotificationController(service: mockService);
  });

  test(
      'scheduleTaskReminder deve chamar scheduleTaskNotification se reminderAt não for nulo',
      () async {
    final task = TaskEntity(
      id: 'abc123',
      title: 'Testar notificação',
      userId: 'user1',
      createdAt: DateTime.now(),
      reminderAt: DateTime.now().add(const Duration(minutes: 1)),
    );

    when(() => mockService.scheduleTaskNotification(task))
        .thenAnswer((_) async {});

    await controller.scheduleReminderForTask(task);

    verify(() => mockService.scheduleTaskNotification(task)).called(1);
  });



  
}
