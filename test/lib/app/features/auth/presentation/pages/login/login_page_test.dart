import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/pages/login/login_page.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';

class FakeAuthController extends GetxController implements AuthController {
  final _loading = false.obs;

  @override
  bool get isLoading => _loading.value;
  @override
  set isLoading(bool value) => _loading.value = value;

  void setLoading(bool value) => _loading.value = value;

  @override
  Future<void> loginWithEmail(String email, String password) async {
    // Apenas registrar chamada, sem efeito real
    loginCalls.add([email, password]);
  }

  // Para checar se o método foi chamado
  List<List<String>> loginCalls = [];

  @override
  bool get isLoggedIn => false;

  @override
  Rxn<UserEntity> get person => Rxn<UserEntity>();

  @override
  User? get user => null;

  @override
  Future<void> signUp(String name, String email, String password) async {}

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

  testWidgets('Renderiza título e subtítulo na LoginPage', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const LoginPage()));

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('Preenche campos e chama loginWithEmail', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const LoginPage()));

    final emailField = find.byType(TextFormField).at(0);
    final passField = find.byType(TextFormField).at(1);
    final loginButton = find.byKey(const Key('login_button'));

    await tester.enterText(emailField, 'teste@email.com');
    await tester.enterText(passField, '123456');
    await tester.tap(loginButton);
    await tester.pump();

    // Checa se o método foi chamado com os valores corretos
    expect(fakeController.loginCalls.length, 1);
    expect(fakeController.loginCalls[0][0], 'teste@email.com');
    expect(fakeController.loginCalls[0][1], '123456');
  });

  testWidgets('Mostra loader quando isLoading = true', (tester) async {
    fakeController.setLoading(true);

    await tester.pumpWidget(makeTestableWidget(const LoginPage()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsNothing);
  });
}
