// test/lib/app/features/auth/presentation/widgets/login_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/pages/register/register_page.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/login_form.dart';

// Mock do AuthController para simular seu comportamento

class FakeAuthController extends GetxController implements AuthController {
  @override
  final Rxn<UserEntity> person = Rxn<UserEntity>();
  @override
  final state = ControllerState.initial.obs;
  @override
  bool get isLoggedIn => person.value != null;
  @override
  Future<void> loginWithEmail(String email, String password) async {
    person.value = UserEntity(id: '1', email: email);
    state.value = ControllerState.success;
  }
  @override
  Future<void> signUp(String name, String email, String password) async {
    person.value = UserEntity(id: '1', email: email, name: name);
    state.value = ControllerState.success;
  }
  @override
  Future<void> signOut() async {
    person.value = null;
  }
  @override
  Future<void> getCurrentUser() async {}
  @override
  UserEntity? get currentUser => person.value;
  
  @override
  Widget buildWhen({required Widget Function() onSuccess, Widget Function()? onLoading, Widget Function(String p1)? onError}) {

    throw UnimplementedError();
  }
  
  @override
  Rxn<String> get errorMessage => throw UnimplementedError();
}

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeAuthController fakeAuthController;
  late GlobalKey<FormState> formKey;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final mockAuthController = FakeAuthController();
  setUp(() {
    Get.testMode = true;
    fakeAuthController = FakeAuthController();
    formKey = GlobalKey<FormState>();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    if (!Get.isRegistered<RouteObserver>()) {
      Get.put<RouteObserver>(RouteObserver<PageRoute>());
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(fakeAuthController);
    }
  });

  tearDown(() {
    Get.reset();
    emailController.dispose();
    passwordController.dispose();
  });

  Widget makeTestableWidget() {
    return GetMaterialApp(
      home: Scaffold(
        body: LoginFormContainer(
          authController: mockAuthController,
          formKey: formKey,
          emailController: emailController,
          passwordController: passwordController,
        ),
      ),
      navigatorObservers: [Get.find<RouteObserver>()],
    );
  }

  group('LoginFormContainer', () {
    testWidgets('should render login form with all widgets', (tester) async {
      await tester.pumpWidget(makeTestableWidget());
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (tester) async {
      await tester.pumpWidget(makeTestableWidget());
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should call loginWithEmail on controller with valid data', (tester) async {
      await tester.pumpWidget(makeTestableWidget());
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(fakeAuthController.person.value?.email, 'test@example.com');
      expect(fakeAuthController.state.value, ControllerState.success);
    });

    testWidgets('should show a loading indicator when controller is loading', (tester) async {
      fakeAuthController.state.value = ControllerState.loading;
      await tester.pumpWidget(makeTestableWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should navigate to RegisterPage when Sign Up button is pressed', (tester) async {
      await tester.pumpWidget(makeTestableWidget());
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterPage), findsOneWidget);
    });
  });
}