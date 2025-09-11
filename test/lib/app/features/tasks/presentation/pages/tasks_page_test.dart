// test/lib/app/features/tasks/presentation/pages/tasks_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';
import 'package:list_firebase/app/features/tasks/domain/task_repository.dart';
import 'package:list_firebase/app/features/tasks/presentation/controller/task_controller.dart';
import 'package:list_firebase/app/features/tasks/presentation/pages/tasks_page.dart';
import 'package:list_firebase/app/features/tasks/presentation/widgets/addtask_page.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {
@override
Stream<List<TaskEntity>> watchTasks(String userId) {
  return Stream.value([
    TaskEntity(
      id: '1', 
      title: 'Task 1', 
      userId: userId, 
      createdAt: DateTime.now()
    )
  ]);
}

}



class MockNotificationController extends Mock
    implements NotificationController {}

// Fake necessário para `any<TaskEntity>()`
class FakeTaskEntity extends Fake implements TaskEntity {}

void main() {
  late MockTaskRepository mockRepo;
  late MockNotificationController mockNotif;
  late TaskController controller;

  setUpAll(() {
    registerFallbackValue(FakeTaskEntity());
    Get.testMode = true; // desativa snackbars reais
  });

  setUp(() {
    mockRepo = MockTaskRepository();
    mockNotif = MockNotificationController();

    controller = TaskController(
      repository: mockRepo,
      notificationController: mockNotif,
    );

    Get.put<TaskController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

 group('HomePage', () {
  group('Renderização', () {
    testWidgets('mostra tasks na tela', (tester) async {
      controller.tasks.assignAll([
        TaskEntity(id: '1', title: 'Task 1', userId: 'u1', createdAt: DateTime.now()),
        TaskEntity(id: '2', title: 'Task 2', userId: 'u1', createdAt: DateTime.now(), isDone: true),
      ]);
      await tester.pumpWidget(GetMaterialApp(home: HomePage(userId: 'u1')));
      await tester.pumpAndSettle();

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
    });

    testWidgets('mostra mensagem quando não há tasks', (tester) async {
      controller.tasks.clear();
      await tester.pumpWidget(GetMaterialApp(home: HomePage(userId: 'u1')));
      await tester.pumpAndSettle();
      expect(find.text('No tasks found'), findsOneWidget);
    });
  });

  group('Navegação', () {
    testWidgets('navega para AddTaskPage ao clicar no FAB', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: HomePage(userId: 'u1')));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddTaskPage), findsOneWidget);
    });

    testWidgets('aciona edição ao clicar no Slidable Edit', (tester) async {
      final task = TaskEntity(id: '1', title: 'Task 1', userId: 'u1', createdAt: DateTime.now());
      controller.tasks.assignAll([task]);

      await tester.pumpWidget(GetMaterialApp(home: HomePage(userId: 'u1')));
      await tester.pumpAndSettle();

      await tester.drag(find.text('Task 1'), const Offset(500, 0));
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.byType(AddTaskPage), findsOneWidget);
    });
  });

  group('Ações', () {
    testWidgets('aciona updateTask ao clicar no checkbox', (tester) async {
      final task = TaskEntity(id: '1', title: 'Task 1', userId: 'u1', createdAt: DateTime.now());
      controller.tasks.assignAll([task]);
      when(() => mockRepo.updateTask(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(GetMaterialApp(home: HomePage(userId: 'u1')));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      verify(() => mockRepo.updateTask('u1', any<TaskEntity>())).called(1);
    });

    testWidgets('aciona deleteTask ao clicar em Delete', (tester) async {
      final task = TaskEntity(id: '1', title: 'Task 1', userId: 'u1', createdAt: DateTime.now());
      controller.tasks.assignAll([task]);
      when(() => mockRepo.deleteTask(any(), any())).thenAnswer((_) async {});
      when(() => mockNotif.cancelRemindersForTask(any())).thenAnswer((_) async {});

      await tester.pumpWidget(GetMaterialApp(home: HomePage(userId: 'u1')));
      await tester.pump();

      await tester.drag(find.text('Task 1'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();

      verify(() => mockRepo.deleteTask('u1', '1')).called(1);
      verify(() => mockNotif.cancelRemindersForTask(task)).called(1);
    });
  });
});

}
