import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/login_form.dart';

// Mock gerado manualmente
class MockAuthController extends Mock implements AuthController {
  final RxBool _loading = false.obs;

  @override
  bool get isLoading => _loading.value;

  void setLoading(bool value) => _loading.value = value;

  @override
  Future<void> loginWithEmail(String email, String password) async {
    return super.noSuchMethod(
      Invocation.method(#loginWithEmail, [email, password]),
      returnValue: Future.value(),
    );
  }
}

void main() {
  late MockAuthController mockController;
  late GlobalKey<FormState> formKey;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  setUp(() {
    mockController = MockAuthController();
    formKey = GlobalKey<FormState>();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  });

  Widget makeTestableWidget(Widget child) {
    return GetMaterialApp(
      home: Scaffold(body: child),
    );
  }

  testWidgets('Renderiza campos de email, senha e botão de login',
      (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(
      LoginFormContainer(
        authController: mockController,
        formKey: formKey,
        emailController: emailController,
        passwordController: passwordController,
      ),
    ));

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });

  testWidgets('Validação do formulário mostra erro se campos vazios',
      (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(
      LoginFormContainer(
        authController: mockController,
        formKey: formKey,
        emailController: emailController,
        passwordController: passwordController,
      ),
    ));

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('Chama loginWithEmail quando formulário é válido',
      (WidgetTester tester) async {
    emailController.text = 'test@email.com';
    passwordController.text = '123456';

    await tester.pumpWidget(makeTestableWidget(
      LoginFormContainer(
        authController: mockController,
        formKey: formKey,
        emailController: emailController,
        passwordController: passwordController,
      ),
    ));

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    verify(mockController.loginWithEmail('test@email.com', '123456'))
        .called(1);
  });

  testWidgets('Mostra CircularProgressIndicator quando isLoading = true',
      (WidgetTester tester) async {
    mockController.setLoading(true);

    await tester.pumpWidget(makeTestableWidget(
      LoginFormContainer(
        authController: mockController,
        formKey: formKey,
        emailController: emailController,
        passwordController: passwordController,
      ),
    ));

    await tester.pump(); // reconstruir com Obx

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsNothing);
  });
}
