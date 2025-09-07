// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:get/get.dart';
// import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
// import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';
// import 'package:list_firebase/app/features/tasks/presentation/controller/task_controller.dart';
// import 'package:list_firebase/app/features/tasks/presentation/pages/addtask_page.dart';
// import 'package:mockito/mockito.dart';

// // Mocks
// class MockTaskController extends Mock implements TaskController {}
// class MockNotificationController extends Mock implements NotificationController {}

// void main() {
//   late MockTaskController mockTaskController;
//   late MockNotificationController mockNotificationController;

//   setUp(() {
//     mockTaskController = MockTaskController();
//     mockNotificationController = MockNotificationController();

//     // Dependências do GetX
//     Get.reset();
//     Get.put<TaskController>(mockTaskController);
//     Get.put<NotificationController>(mockNotificationController);
//   });

//   // Função para criar a página com TaskEntity opcional
//   Future<void> pumpAddTaskPage(WidgetTester tester, {TaskEntity? existingTask}) async {
//     await tester.pumpWidget(
//       GetMaterialApp(
//         home: AddTaskPage(existingTask: existingTask),
//         initialBinding: BindingsBuilder(() {
//           Get.parameters['userId'] = 'testUser';
//         }),
//       ),
//     );
//     await tester.pumpAndSettle();
//   }

//   // Entidade de teste personalizada
//   TaskEntity createCustomTask() {
//     return TaskEntity(
//       id: 'task123',
//       title: 'Custom Task',
//       description: 'Descrição personalizada',
//       userId: 'testUser',
//       createdAt: DateTime.now(),
//       isDone: false,
//       repeatType: 'weekly',
//       weekDays: [1, 3, 5], // Seg, Qua, Sex
//       reminderTime: '08:30',
//       reminderAt: DateTime.now().add(Duration(hours: 1)),
//     );
//   }

//   group('AddTaskPage Tests', () {
//     testWidgets('Shows validation error if title is empty', (WidgetTester tester) async {
//       await pumpAddTaskPage(tester);

//       await tester.tap(find.text('Save Task'));
//       await tester.pump();

//       expect(find.text('Title cannot be empty'), findsOneWidget);
//       verifyNever(mockTaskController.addTask(any, any, any));
//     });

//     testWidgets('Can add a new task', (WidgetTester tester) async {
//       await pumpAddTaskPage(tester);

//       await tester.enterText(find.byType(TextFormField).first, 'Test Task');
//       await tester.enterText(find.byType(TextFormField).at(1), 'Description');

//       when(mockTaskController.addTask('testUser', 'Test Task', 'Description'))
//           .thenAnswer((_) async {});

//       await tester.tap(find.text('Save Task'));
//       await tester.pumpAndSettle();

//       verify(mockTaskController.addTask('testUser', 'Test Task', 'Description'))
//           .called(1);
//     });

//     testWidgets('Can edit an existing task', (WidgetTester tester) async {
//       final existingTask = createCustomTask();

//       await pumpAddTaskPage(tester, existingTask: existingTask);

//       await tester.enterText(find.byType(TextFormField).first, 'Updated Task');

//       when(mockTaskController.updateTask('testUser', TaskEntity.createCustomTask))
//           .thenAnswer((_) async {});

//       await tester.tap(find.text('Save Changes'));
//       await tester.pumpAndSettle();

//       verify(mockTaskController.updateTask('testUser', any)).called(1);
//     });

//     testWidgets('Can select reminder time', (WidgetTester tester) async {
//       await pumpAddTaskPage(tester);

//       await tester.tap(find.text('Select Time'));
//       await tester.pumpAndSettle();

//       // Simula escolher hora
//       await tester.tap(find.text('OK').first);
//       await tester.pumpAndSettle();
//     });
//   });
// }
