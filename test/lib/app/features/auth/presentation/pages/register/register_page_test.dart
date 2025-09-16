// test/lib/app/features/auth/presentation/pages/register/register_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/pages/register/register_page.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/register_form.dart';

// Mock the AuthController to control its state for testing.
class MockAuthController extends GetxController with BaseState implements AuthController {
  // Override `buildWhen` to test the UI logic correctly.
  @override
  Widget buildWhen({
    required Widget Function() onSuccess,
    Widget Function()? onLoading,
    Widget Function(String)? onError,
  }) {
    // This override allows the test to manually control the state.
    return Obx(() {
      if (state.value == ControllerState.loading) {
        return onLoading?.call() ?? const CircularProgressIndicator();
      }
      if (state.value == ControllerState.error) {
        return onError?.call(errorMessage.value ?? 'Error') ?? const Text('Error');
      }
      return onSuccess();
    });
  }

  // Mock methods to prevent errors during tests
  @override
  Future<void> getCurrentUser() async {}
  @override
  Future<void> signUp(String name, String email, String password) async {}
  @override
  Future<void> loginWithEmail(String email, String password) async {}
  @override
  Future<void> signOut() async {}

  @override
  Rxn<UserEntity> person = Rxn<UserEntity>();

  @override
  bool get isLoggedIn => person.value != null;
  
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAuthController mockAuthController;

  setUp(() {
    mockAuthController = MockAuthController();
    Get.testMode = true;
    Get.put<AuthController>(mockAuthController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget makeTestableWidget() {
    return const GetMaterialApp(
      home: RegisterPage(),
    );
  }

  group('RegisterPage', () {
    testWidgets('should render all static widgets correctly', (tester) async {
      // Arrange
      mockAuthController.state.value = ControllerState.success;
      await tester.pumpWidget(makeTestableWidget());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Register'), findsWidgets);
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.byType(RegisterFormContainer), findsOneWidget);
    });

    testWidgets('should show loading indicator when AuthController is in loading state', (tester) async {
      // Arrange
      mockAuthController.state.value = ControllerState.loading;
      await tester.pumpWidget(makeTestableWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(RegisterFormContainer), findsNothing);
    });

    testWidgets('should show RegisterFormContainer when AuthController is in success state', (tester) async {
      // Arrange
      mockAuthController.state.value = ControllerState.success;
      await tester.pumpWidget(makeTestableWidget());

      // Assert
      expect(find.byType(RegisterFormContainer), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show RegisterFormContainer when AuthController is in error state', (tester) async {
      // Arrange
      mockAuthController.state.value = ControllerState.error;
      await tester.pumpWidget(makeTestableWidget());

      // Assert
      // In this specific implementation, we decided to show the form again on error.
      expect(find.byType(RegisterFormContainer), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}