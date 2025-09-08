import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/auth/presentation/pages/register/register_page.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/register_form.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';

class FakeAuthController extends GetxController implements AuthController {
  final _loading = false.obs;
  List<List<String>> signUpCalls = [];

  @override
  bool get isLoading => _loading.value;
  @override
  set isLoading(bool value) => _loading.value = value;
  void setLoading(bool value) => _loading.value = value;

  @override
  Future<void> signUp(String name, String email, String password) async {
    signUpCalls.add([name, email, password]);
  }

  @override
  bool get isLoggedIn => false;
  @override
  Rxn<UserEntity> get person => Rxn<UserEntity>();
  @override
  User? get user => null;
  @override
  Future<void> loginWithEmail(String email, String password) async {}
  @override
  Future<void> signOut() async {}
  @override
  void Function(String title, String message)? get onError => null;
}

void main() {
  late FakeAuthController fakeController;

  setUp(() {
    Get.testMode = true;
    fakeController = FakeAuthController();
    Get.put<AuthController>(fakeController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget makeTestableWidget(Widget child) {
    return GetMaterialApp(home: child);
  }

  testWidgets('Renderiza títulos e RegisterForm', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const RegisterPage()));

    // Verifica se os títulos estão presentes
    expect(find.text('Register'), findsWidgets);
    expect(find.text('Create your account'), findsOneWidget);

    // Verifica se o RegisterFormContainer está presente
    expect(find.byType(RegisterFormContainer), findsOneWidget);
  });

  testWidgets('Chama signUp ao preencher formulário e apertar Register', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const RegisterPage()));

    // Encontra os TextFormFields do RegisterFormContainer
    final nameField = find.byType(TextFormField).at(0);
    final emailField = find.byType(TextFormField).at(1);
    final passwordField = find.byType(TextFormField).at(2);
    final confirmField = find.byType(TextFormField).at(3);
    final registerButton = find.byKey(const Key('register_button'));

    // Preenche os campos com dados válidos
    await tester.enterText(nameField, 'Selma');
    await tester.enterText(emailField, 'selma@email.com');
    await tester.enterText(passwordField, 'Abc123!');
    await tester.enterText(confirmField, 'Abc123!');

    // Toca no botão
    await tester.tap(registerButton);
    await tester.pump();

    // Verifica se o método signUp foi chamado
    expect(fakeController.signUpCalls.length, 1);
    expect(fakeController.signUpCalls[0][0], 'Selma');
    expect(fakeController.signUpCalls[0][1], 'selma@email.com');
    expect(fakeController.signUpCalls[0][2], 'Abc123!');
  });

  testWidgets('Mostra loader quando isLoading = true', (tester) async {
    fakeController.setLoading(true);
    await tester.pumpWidget(makeTestableWidget(const RegisterPage()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('register_button')), findsOneWidget);
  });
}
