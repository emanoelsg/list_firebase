import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/register_form.dart';

class FakeAuthController extends GetxController implements AuthController {
  final _loading = false.obs;

  @override
  bool get isLoading => _loading.value;
  @override
  set isLoading(bool value) => _loading.value = value;

  void setLoading(bool value) => _loading.value = value;

  List<List<String>> signUpCalls = [];

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
  late GlobalKey<FormState> formKey;
  late TextEditingController nameCtrl, emailCtrl, passCtrl, confirmCtrl;

  setUp(() {
    Get.testMode = true;
    fakeController = FakeAuthController();
    Get.put<AuthController>(fakeController);

    formKey = GlobalKey<FormState>();
    nameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    passCtrl = TextEditingController();
    confirmCtrl = TextEditingController();
  });

  tearDown(() {
    Get.reset();
  });

  Widget makeTestableWidget(Widget child) {
    return GetMaterialApp(home: Scaffold(body: child));
  }

  testWidgets('Renderiza todos os campos e botão Register', (tester) async {
    await tester.pumpWidget(makeTestableWidget(
      RegisterFormContainer(
        authController: fakeController,
        formKey: formKey,
        nameController: nameCtrl,
        emailController: emailCtrl,
        passwordController: passCtrl,
        confirmPasswordController: confirmCtrl,
      ),
    ));

    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.byKey(const Key('register_button')), findsOneWidget);
  });

 testWidgets('Validação do formulário com campos vazios', (tester) async {
  await tester.pumpWidget(makeTestableWidget(
    RegisterFormContainer(
      authController: fakeController,
      formKey: formKey,
      nameController: nameCtrl,
      emailController: emailCtrl,
      passwordController: passCtrl,
      confirmPasswordController: confirmCtrl,
    ),
  ));

  await tester.tap(find.byKey(const Key('register_button')));
  await tester.pump();

  // Cada campo deve exibir erro de validação
  expect(find.text('Username is required.'), findsOneWidget);
  expect(find.text('Email is required.'), findsOneWidget);
  expect(find.text('Password is required.'), findsOneWidget);
  expect(find.text('Confirm password is required'), findsOneWidget);
});


 testWidgets('Chama signUp quando formulário válido', (tester) async {
  nameCtrl.text = 'Selma';
  emailCtrl.text = 'selma@email.com';
  passCtrl.text = 'Abc123!'; // senha válida
  confirmCtrl.text = 'Abc123!';

  await tester.pumpWidget(makeTestableWidget(
    RegisterFormContainer(
      authController: fakeController,
      formKey: formKey,
      nameController: nameCtrl,
      emailController: emailCtrl,
      passwordController: passCtrl,
      confirmPasswordController: confirmCtrl,
    ),
  ));

  await tester.tap(find.byKey(const Key('register_button')));
  await tester.pump();

  expect(fakeController.signUpCalls.length, 1);
  expect(fakeController.signUpCalls[0][0], 'Selma');
  expect(fakeController.signUpCalls[0][1], 'selma@email.com');
  expect(fakeController.signUpCalls[0][2], 'Abc123!');
});
  testWidgets('Mostra loader quando isLoading = true', (tester) async {
    fakeController.setLoading(true);

    await tester.pumpWidget(makeTestableWidget(
      RegisterFormContainer(
        authController: fakeController,
        formKey: formKey,
        nameController: nameCtrl,
        emailController: emailCtrl,
        passwordController: passCtrl,
        confirmPasswordController: confirmCtrl,
      ),
    ));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('register_button')), findsOneWidget);
  });
}
