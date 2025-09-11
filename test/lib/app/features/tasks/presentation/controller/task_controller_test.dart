// test/lib/app/features/tasks/presentation/controller/task_controller_test.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';
import 'package:list_firebase/app/features/tasks/domain/task_repository.dart';
import 'package:list_firebase/app/features/tasks/presentation/controller/task_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockNotificationController extends Mock
    implements NotificationController {}

class FakeTaskEntity extends Fake implements TaskEntity {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TaskController controller;
  late MockTaskRepository mockRepository;
  late MockNotificationController mockNotif;
  const userId = 'user123';
  late StreamController<List<TaskEntity>> taskStreamController;

  setUpAll(() {
    registerFallbackValue(FakeTaskEntity());
  });

  setUp(() {
    mockRepository = MockTaskRepository();
    mockNotif = MockNotificationController();
    taskStreamController = StreamController<List<TaskEntity>>.broadcast();

    // watchTasks devolve um stream controlável
    when(() => mockRepository.watchTasks(userId))
        .thenAnswer((_) => taskStreamController.stream);

    controller = TaskController(
      repository: mockRepository,
      notificationController: mockNotif,
    );
  });

  tearDown(() async {
    await taskStreamController.close();
  });

  group('TaskController', () {
    test('loadTasks deve ouvir o stream e atualizar tasks', () async {
      controller.loadTasks(userId);

      final sampleTask = TaskEntity(
        id: '1',
        title: 'Test Task',
        userId: userId,
        createdAt: DateTime.now(),
      );

      taskStreamController.add([sampleTask]);
      await Future.delayed(Duration.zero);

      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.title, 'Test Task');
      expect(controller.isLoading.value, false);
    });

    test('addTask deve salvar no repo e agendar notificação se reminderTime != null', () async {
      when(() => mockRepository.addTask(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockNotif.scheduleReminderForTask(any()))
          .thenAnswer((_) async {});

      await controller.addTask(
        userId,
        'Nova Task',
        '',
        reminderTime: '08:00',
      );

      verify(() => mockRepository.addTask(userId, any())).called(1);
      verify(() => mockNotif.scheduleReminderForTask(any())).called(1);
      expect(controller.error.value, '');
    });

    test('updateTask deve chamar update, cancelar e agendar notificação', () async {
      final t = TaskEntity(
        id: '1',
        title: 'Task',
        userId: userId,
        createdAt: DateTime.now(),
      );

      when(() => mockRepository.updateTask(userId, any()))
          .thenAnswer((_) async {});
      when(() => mockNotif.cancelRemindersForTask(any()))
          .thenAnswer((_) async {});
      when(() => mockNotif.scheduleReminderForTask(any()))
          .thenAnswer((_) async {});

      await controller.updateTask(userId, t, reminderTime: '09:00');

      verify(() => mockRepository.updateTask(userId, any())).called(1);
      verify(() => mockNotif.cancelRemindersForTask(any())).called(1);
      verify(() => mockNotif.scheduleReminderForTask(any())).called(1);
    });

    test('deleteTask deve remover task e cancelar notificações', () async {
      final t = TaskEntity(
        id: '1',
        title: 'Task',
        userId: userId,
        createdAt: DateTime.now(),
      );

      controller.tasks.value = [t];
      when(() => mockRepository.deleteTask(userId, t.id))
          .thenAnswer((_) async {});
      when(() => mockNotif.cancelRemindersForTask(any()))
          .thenAnswer((_) async {});

      await controller.deleteTask(userId, t.id);

      verify(() => mockRepository.deleteTask(userId, t.id)).called(1);
      verify(() => mockNotif.cancelRemindersForTask(t)).called(1);
    });
  });
}
