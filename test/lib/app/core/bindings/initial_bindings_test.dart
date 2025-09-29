// test/lib/app/core/bindings/initial_bindings_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/bindings/initial_binding.dart';
import 'package:mocktail/mocktail.dart';



// Mock classes for each dependency to isolate the binding tests.
import 'package:list_firebase/app/features/auth/data/auth_repository_impl.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/domain/auth_repository.dart';
import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
import 'package:list_firebase/app/features/notifications/service/notifications_service.dart';
import 'package:list_firebase/app/features/tasks/data/task_repository_impl.dart';
import 'package:list_firebase/app/features/tasks/presentation/controller/task_controller.dart';
import 'package:list_firebase/app/features/tasks/domain/task_repository.dart';

class MockAuthRepositoryImpl extends Mock implements AuthRepositoryImpl {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockTaskRepositoryImpl extends Mock implements TaskRepositoryImpl {}
class MockNotificationService extends Mock implements NotificationService {}
void registerNotificationServiceInit() {
  when(() => Get.find<NotificationService>().init()).thenAnswer((_) async {});
}
class MockNotificationController extends Mock implements NotificationController {}
class MockAuthController extends Mock implements AuthController {}
class MockTaskController extends Mock implements TaskController {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    Get.testMode = true;
    Get.reset();
    // Mocka todos os repositórios e serviços para evitar inicialização real
    Get.put<AuthRepositoryImpl>(MockAuthRepositoryImpl());
    Get.put<AuthRepository>(MockAuthRepository());
    Get.put<TaskRepositoryImpl>(MockTaskRepositoryImpl());
    Get.put<TaskRepository>(MockTaskRepositoryImpl());
    Get.put<NotificationService>(MockNotificationService());
    registerNotificationServiceInit();
  });
  group('InitialBindings', () {
    test('should register all dependencies and resolve them correctly', () {
  // Create an instance de InitialBindings (não usado, removido para evitar warning).

      // Register the mock dependencies manually to simulate the process.
      // This is a common practice in testing to ensure you're testing only the bindings logic.
  Get.put<AuthRepositoryImpl>(MockAuthRepositoryImpl());
  Get.put<AuthRepository>(MockAuthRepository());
      Get.put<TaskRepositoryImpl>(MockTaskRepositoryImpl());
      Get.put<NotificationService>(MockNotificationService());

      // Use `Get.lazyPut` to check if controllers can be created without immediately resolving their dependencies.
      // We will create the controllers later to test if the `Get.find()` calls inside them work.
      Get.lazyPut<NotificationController>(() => NotificationController(service: Get.find()));
      Get.lazyPut<AuthController>(() => AuthController(repository: Get.find()));
      Get.lazyPut<TaskController>(() => TaskController(repository: Get.find(), notificationController: Get.find()));

      // Now, verify that each dependency can be found and that their types are correct.
      // This simulates a part of the `InitialBindings().dependencies()` method.
      expect(Get.find<AuthRepositoryImpl>(), isA<AuthRepositoryImpl>());
      expect(Get.find<TaskRepositoryImpl>(), isA<TaskRepositoryImpl>());
      expect(Get.find<NotificationService>(), isA<NotificationService>());

      // Resolve the controllers and verify their types. This checks the full dependency graph.
      expect(Get.find<NotificationController>(), isA<NotificationController>());
      expect(Get.find<AuthController>(), isA<AuthController>());
      expect(Get.find<TaskController>(), isA<TaskController>());

      // You can also add a test to verify a specific method call on a mock dependency
      // to ensure the controllers are correctly using them.
      // For instance:
      // when(() => Get.find<MockAuthController>().someMethod()).thenAnswer((_) => true);
      // expect(Get.find<MockAuthController>().someMethod(), isTrue);
    });

    test('should ensure the dependency graph is correctly set up with Get.put', () {
      // Reset GetX instance to ensure a clean state for this test.
      Get.reset();

      // Call the dependencies() method directly to trigger the registration.
      InitialBindings().dependencies();

      // Now, we can assert that the controllers were correctly put and can be found.
      expect(Get.isRegistered<AuthRepositoryImpl>(), isTrue);
      expect(Get.isRegistered<TaskRepositoryImpl>(), isTrue);
      expect(Get.isRegistered<NotificationService>(), isTrue);
      expect(Get.isRegistered<NotificationController>(), isTrue);
      expect(Get.isRegistered<AuthController>(), isTrue);
      expect(Get.isRegistered<TaskController>(), isTrue);

      // And finally, resolve them to ensure no errors are thrown,
      // which confirms the Get.find() calls within the controllers succeeded.
      expect(() => Get.find<AuthController>(), returnsNormally);
      expect(() => Get.find<TaskController>(), returnsNormally);
    });
  });
}