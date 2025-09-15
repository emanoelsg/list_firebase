// test/lib/app/features/auth/presentation/widgets/register_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/register_form.dart';
import 'package:mocktail/mocktail.dart';

// Mock do AuthController para simular seu comportamento
class MockAuthController extends GetxController with BaseState implements AuthController {
  @override
  Rxn<UserEntity> person = Rxn<UserEntity>();

  @override
  bool get isLoggedIn => person.value != null;

  @override
  Future<void> loginWithEmail(String email, String password) async {}
  @override
  Future<void> signUp(String name, String email, String password) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> getCurrentUser() async {}
  
  @override
  final RxBool hasError = false.obs;
  @override
  final RxBool isLoading = false.obs;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthController mockAuthController;
  late GlobalKey<FormState> formKey;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  setUp(() {
    Get.testMode = true;
    mockAuthController = MockAuthController();
    formKey = GlobalKey<FormState>();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    Get.put<AuthController>(mockAuthController);
    // Estado inicial
    mockAuthController.state.value = ControllerState.initial;
  });

  tearDown(() {
    Get.reset();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
  mockAuthController.state.value = ControllerState.initial;
  await tester.pumpWidget(makeTestableWidget());

      // Verifica se todos os campos e botões estão presentes
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.byKey(const Key('register_button')), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (tester) async {
  mockAuthController.state.value = ControllerState.initial;
  await tester.pumpWidget(makeTestableWidget());

      // Toca no botão de registro sem preencher nada
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pump();

      // Verifica se as mensagens de erro de validação aparecem
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should call signUp on controller with valid data', (tester) async {
  mockAuthController.state.value = ControllerState.initial;
  await tester.pumpWidget(makeTestableWidget());

      // Preenche os campos com dados válidos
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john.doe@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      // Toca no botão de registro
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pump();

      // Verifica se o método `signUp` foi chamado com os dados corretos
      verify(() => mockAuthController.signUp('John Doe', 'john.doe@example.com', 'password123')).called(1);
    });

    testWidgets('should show loading indicator when controller state is loading', (tester) async {
  mockAuthController.state.value = ControllerState.loading;
  await tester.pumpWidget(makeTestableWidget());

      // Verifica se o indicador de progresso está visível e o botão de registro não
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('register_button')), findsNothing);
    });
  });
}