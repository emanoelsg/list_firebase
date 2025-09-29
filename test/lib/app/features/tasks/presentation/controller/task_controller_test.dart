// test/lib/app/features/tasks/presentation/controller/task_controller_test.dart

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';
import 'package:list_firebase/app/features/tasks/domain/task_repository.dart';
import 'package:list_firebase/app/features/tasks/presentation/controller/task_controller.dart';
import 'package:mocktail/mocktail.dart';

// Mocks e Fakes
class MockTaskRepository extends Mock implements TaskRepository {}
class MockNotificationController extends Mock implements NotificationController {}
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
    test('loadTasks deve mudar o estado para success e atualizar tasks', () async {
      // 1. Inicia o carregamento
      controller.loadTasks(userId);
      expect(controller.state.value, TaskControllerState.loading);

      // 2. Adiciona dados ao stream (simula o sucesso)
      final sampleTask = TaskEntity(
        id: '1',
        title: 'Test Task',
        userId: userId,
        createdAt: DateTime.now(),
      );
      taskStreamController.add([sampleTask]);
      await Future.delayed(Duration.zero);

      // 3. Verifica o estado e os dados
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.title, 'Test Task');
      expect(controller.state.value, TaskControllerState.success);
    });

    test('loadTasks deve mudar o estado para error em caso de falha', () async {
      // 1. Inicia o carregamento
      controller.loadTasks(userId);
      expect(controller.state.value, TaskControllerState.loading);

      // 2. Adiciona um erro ao stream
      taskStreamController.addError('Falha de conexão');
      await Future.delayed(Duration.zero);

      // 3. Verifica o estado e a mensagem de erro
      expect(controller.state.value, TaskControllerState.error);
      expect(controller.errorMessage.value, contains('Falha de conexão'));
    });

    test('addTask deve mudar o estado para loading e depois para success', () async {
      when(() => mockRepository.addTask(any(), any())).thenAnswer((_) async {});
      when(() => mockNotif.scheduleReminderForTask(any())).thenAnswer((_) async {});

      final future = controller.addTask(
        userId,
        'Nova Task',
        '',
        reminderTime: '08:00',
      );

      // Estado deve ser loading durante a execução
      expect(controller.state.value, TaskControllerState.loading);

      await future;

      // Estado deve ser success após a conclusão
      expect(controller.state.value, TaskControllerState.success);
      verify(() => mockRepository.addTask(userId, any())).called(1);
      verify(() => mockNotif.scheduleReminderForTask(any())).called(1);
      expect(controller.errorMessage.value, isNull);
    });
  });
}