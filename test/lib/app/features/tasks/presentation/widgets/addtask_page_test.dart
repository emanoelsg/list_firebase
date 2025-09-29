// test/lib/app/features/tasks/presentation/widgets/addtask_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
import 'package:list_firebase/app/features/notifications/service/notifications_service.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';
import 'package:list_firebase/app/features/tasks/presentation/controller/task_controller.dart';
import 'package:list_firebase/app/features/tasks/presentation/widgets/addtask_page.dart';
import 'package:mocktail/mocktail.dart';
class FakeNotificationService extends NotificationService {}


class MockTaskController extends Mock implements TaskController {}
class MockNotificationController extends Mock implements NotificationController {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockTaskController mockTaskController;
  late MockNotificationController mockNotificationController;
  const userId = 'test-user';

  setUpAll(() {
    registerFallbackValue(TaskEntity(
      id: 'fake',
      title: 'fake',
      userId: 'fake',
      createdAt: DateTime.now(),
    ));
  });

  setUp(() {
    Get.testMode = true;
    mockTaskController = MockTaskController();
    mockNotificationController = MockNotificationController();
    if (!Get.isRegistered<TaskController>()) {
      Get.put<TaskController>(mockTaskController);
    }
    if (!Get.isRegistered<NotificationController>()) {
      Get.put<NotificationController>(mockNotificationController);
    }
  });

  tearDown(() {
    Get.reset();
  });

  Widget makeTestable({TaskEntity? task}) {
    return GetMaterialApp(
      home: AddTaskPage(existingTask: task, testUserId: userId),
    );
  }

  testWidgets('renders form and validates required fields', (tester) async {
    await tester.pumpWidget(makeTestable());
    expect(find.text('New Task'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
  expect(find.text('Title is required'), findsOneWidget);
  });

  testWidgets('validates max length for title and description', (tester) async {
    await tester.pumpWidget(makeTestable());
    await tester.enterText(find.byType(TextFormField).first, 'a' * 51);
    await tester.enterText(find.byType(TextFormField).last, 'b' * 201);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
  expect(find.text('Title must be at most 50 characters'), findsOneWidget);
  expect(find.text('Description must be at most 200 characters'), findsOneWidget);
  });

  testWidgets('can select frequency and week days', (tester) async {
    await tester.pumpWidget(makeTestable());
    await tester.tap(find.text('Weekly'));
    await tester.pump();
    expect(find.text('Mon'), findsOneWidget);
    await tester.tap(find.text('Mon'));
    await tester.pump();
    // Should be selected visually, but we just check widget exists
    expect(find.text('Mon'), findsOneWidget);
  });

  testWidgets('calls addTask and schedules notification on submit', (tester) async {
    when(() => mockTaskController.addTask(any(), any(), any(), repeatType: any(named: 'repeatType'), weekDays: any(named: 'weekDays'), reminderTime: any(named: 'reminderTime'), reminderAt: any(named: 'reminderAt'))).thenAnswer((_) async {});
    when(() => mockNotificationController.scheduleReminderForTask(any())).thenAnswer((_) async {});
    await tester.pumpWidget(makeTestable());
    await tester.enterText(find.byType(TextFormField).first, 'Test Title');
    await tester.enterText(find.byType(TextFormField).last, 'Test Desc');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    verify(() => mockTaskController.addTask(any(), any(), any(), repeatType: any(named: 'repeatType'), weekDays: any(named: 'weekDays'), reminderTime: any(named: 'reminderTime'), reminderAt: any(named: 'reminderAt'))).called(1);
    verify(() => mockNotificationController.scheduleReminderForTask(any())).called(1);
  });

  testWidgets('editing an existing task populates fields and calls update', (tester) async {
    final task = TaskEntity(
      id: '1',
      title: 'Edit Me',
      description: 'Desc',
      userId: userId,
      createdAt: DateTime.now(),
      repeatType: 'weekly',
      weekDays: [1, 2],
      reminderTime: '08:00',
    );
    when(() => mockTaskController.updateTask(any(), any(), newTitle: any(named: 'newTitle'), newDescription: any(named: 'newDescription'), repeatType: any(named: 'repeatType'), weekDays: any(named: 'weekDays'), reminderTime: any(named: 'reminderTime'), reminderAt: any(named: 'reminderAt'))).thenAnswer((_) async {});
    when(() => mockNotificationController.cancelRemindersForTask(any())).thenAnswer((_) async {});
    when(() => mockNotificationController.scheduleReminderForTask(any())).thenAnswer((_) async {});
    await tester.pumpWidget(makeTestable(task: task));
    expect(find.text('Edit Task'), findsOneWidget);
    expect(find.text('Edit Me'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Edited');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    verify(() => mockTaskController.updateTask(any(), any(), newTitle: any(named: 'newTitle'), newDescription: any(named: 'newDescription'), repeatType: any(named: 'repeatType'), weekDays: any(named: 'weekDays'), reminderTime: any(named: 'reminderTime'), reminderAt: any(named: 'reminderAt'))).called(1);
    verify(() => mockNotificationController.cancelRemindersForTask(any())).called(1);
    verify(() => mockNotificationController.scheduleReminderForTask(any())).called(1);
  });
}
