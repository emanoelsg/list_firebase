// test/lib/app/features/auth/presentation/widgets/login_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/pages/register/register_page.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/login_form.dart';
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
  UserEntity? get currentUser => throw UnimplementedError();
  
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MockAuthController mockAuthController;
  late GlobalKey<FormState> formKey;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  setUp(() {
    Get.testMode = true;
    mockAuthController = MockAuthController();
    formKey = GlobalKey<FormState>();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    // Estado inicial
    mockAuthController.state.value = ControllerState.initial;
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
      // Usado para testar a navegação
      navigatorObservers: [Get.find<RouteObserver>()],
    );
  }

  group('LoginFormContainer', () {
    testWidgets('should render login form with all widgets', (tester) async {
  // Simula o estado inicial do controlador
  mockAuthController.state.value = ControllerState.initial;
  await tester.pumpWidget(makeTestableWidget());

      // Verifica se todos os widgets do formulário estão presentes
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (tester) async {
  // Simula o estado inicial do controlador
  mockAuthController.state.value = ControllerState.initial;
  await tester.pumpWidget(makeTestableWidget());

      // Toca no botão de login sem preencher os campos
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verifica se as mensagens de erro de validação aparecem
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should call loginWithEmail on controller with valid data', (tester) async {
  // Simula o estado inicial e o retorno do método `loginWithEmail`
  mockAuthController.state.value = ControllerState.initial;
  await tester.pumpWidget(makeTestableWidget());

      // Preenche os campos com dados válidos
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Toca no botão de login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verifica se o método do controlador foi chamado com os dados corretos
      verify(() => mockAuthController.loginWithEmail('test@example.com', 'password123')).called(1);
    });

    testWidgets('should show a loading indicator when controller is loading', (tester) async {
  // Simula o estado de loading do controlador
  mockAuthController.state.value = ControllerState.loading;
  await tester.pumpWidget(makeTestableWidget());

      // Verifica se o `CircularProgressIndicator` é exibido
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should navigate to RegisterPage when Sign Up button is pressed', (tester) async {
  // Simula o estado inicial do controlador
  mockAuthController.state.value = ControllerState.initial;
  await tester.pumpWidget(makeTestableWidget());

      // Toca no botão de cadastro
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle(); // Espera a animação de navegação terminar

      // Verifica se a `RegisterPage` está agora na tela
      expect(find.byType(RegisterPage), findsOneWidget);
    });
  });
}