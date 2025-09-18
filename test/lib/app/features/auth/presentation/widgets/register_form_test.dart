// test/lib/app/features/auth/presentation/widgets/register_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/register_form.dart';
import 'package:mocktail/mocktail.dart';

// Mock do AuthController
class MockAuthController extends Mock implements AuthController {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthController mockAuthController;
  late GlobalKey<FormState> formKey;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  setUp(() {
    mockAuthController = MockAuthController();
    formKey = GlobalKey<FormState>();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Define estado inicial
    when(() => mockAuthController.state).thenReturn(Rx<ControllerState>(ControllerState.initial));
    when(() => mockAuthController.signUp(any(), any(), any())).thenAnswer((_) async {});
  });

  tearDown(() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    Get.reset();
  });

  Widget makeTestableWidget() {
    return GetMaterialApp(
      home: Scaffold(
        body: RegisterFormContainer(
          authController: mockAuthController,
          formKey: formKey,
          nameController: nameController,
          emailController: emailController,
          passwordController: passwordController,
        ),
      ),
    );
  }

  group('RegisterFormContainer', () {
    testWidgets('should render all form widgets correctly', (tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.byKey(const Key('register_button')), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (tester) async {
      await tester.pumpWidget(makeTestableWidget());

      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pump();

      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should call signUp on controller with valid data', (tester) async {
      await tester.pumpWidget(makeTestableWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john.doe@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pump();

      verify(() => mockAuthController.signUp(
            'John Doe',
            'john.doe@example.com',
            'password123',
          )).called(1);
    });

    testWidgets('should show loading indicator when controller state is loading', (tester) async {
      when(() => mockAuthController.state).thenReturn(Rx<ControllerState>(ControllerState.loading));

      await tester.pumpWidget(makeTestableWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('register_button')), findsNothing);
    });
  });
}
