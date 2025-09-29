// test/lib/app/features/tasks/presentation/pages/tasks_page_test.dart


// Mocks para simular os controladores e serviços
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';
import 'package:list_firebase/app/features/tasks/presentation/controller/task_controller.dart';
import 'package:list_firebase/app/features/tasks/presentation/pages/tasks_page.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskController extends GetxController with Mock implements TaskController {}
class MockAuthController extends GetxController with Mock implements AuthController {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockTaskController mockTaskController;
  late MockAuthController mockAuthController;
  late RouteObserver<Route> routeObserver;

  const userId = 'test-user-id';

  // Configurações iniciais antes de cada teste
  setUp(() {
    mockTaskController = MockTaskController();
    mockAuthController = MockAuthController();
    routeObserver = RouteObserver<Route>();

    when(() => mockAuthController.person).thenReturn(Rxn(UserEntity(id: userId, email: 'test@example.com')));
    when(() => mockTaskController.state).thenReturn(TaskControllerState.initial.obs);
    when(() => mockTaskController.tasks).thenReturn(<TaskEntity>[].obs);
    when(() => mockTaskController.errorMessage).thenReturn(RxnString());

    Get.put<AuthController>(mockAuthController);
    Get.put<TaskController>(mockTaskController);
    Get.put<RouteObserver>(routeObserver);
  });

  tearDown(() {
    Get.reset();
  });

  Widget makeTestableWidget() {
    return GetMaterialApp(
      home: TasksPage(userId: userId),
      navigatorObservers: [routeObserver],
    );
  }

  group('TasksPage Widget Tests', () {
    testWidgets('should show a loading indicator when tasks are loading', (tester) async {
      // ✅ Apenas sobrepõe o stub para este teste específico
      when(() => mockTaskController.state).thenReturn(TaskControllerState.loading.obs);
      await tester.pumpWidget(makeTestableWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show "No tasks found" message when tasks list is empty', (tester) async {
      when(() => mockTaskController.state).thenReturn(TaskControllerState.success.obs);
      when(() => mockTaskController.tasks).thenReturn(<TaskEntity>[].obs);
      await tester.pumpWidget(makeTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma tarefa encontrada. Clique no "+" para adicionar uma.'), findsOneWidget);
    });

    testWidgets('should show a list of tasks when data is available', (tester) async {
      final tasks = [
        TaskEntity(id: '1', title: 'Task 1', description: 'Desc 1', isDone: false, userId: userId, createdAt: DateTime.now()),
        TaskEntity(id: '2', title: 'Task 2', description: 'Desc 2', isDone: true, userId: userId, createdAt: DateTime.now()),
      ];
      
      when(() => mockTaskController.state).thenReturn(TaskControllerState.success.obs);
      when(() => mockTaskController.tasks).thenReturn(tasks.obs);
      await tester.pumpWidget(makeTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}