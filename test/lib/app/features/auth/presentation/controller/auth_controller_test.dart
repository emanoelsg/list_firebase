// test/lib/app/features/auth/presentation/auth_controller_test.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:list_firebase/app/features/auth/domain/auth_repository.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController controller;
  late MockAuthRepository mockRepository;
  late List<String> capturedErrors;

  final mockUser = UserEntity(id: '1', email: 'selma@email.com', name: 'Selma');

  setUp(() {
    Get.testMode = true;
    mockRepository = MockAuthRepository();
    capturedErrors = [];
    controller = AuthController(
      repository: mockRepository,
      onError: (_, msg) => capturedErrors.add(msg),
    );
  });

  group('AuthController', () {
    test('signUp atualiza user quando sucesso', () async {
      when(() => mockRepository.signUp('Selma', 'selma@email.com', 'senha123'))
          .thenAnswer((_) async => mockUser);

      final future = controller.signUp('Selma', 'selma@email.com', 'senha123');

      // durante a execução deve estar carregando
      expect(controller.isLoading, isTrue);

      await future;

      expect(controller.person.value, equals(mockUser));
      expect(controller.isLoading, isFalse);
      verify(() => mockRepository.signUp('Selma', 'selma@email.com', 'senha123')).called(1);
    });

    test('signUp não atualiza user quando falha', () async {
      when(() => mockRepository.signUp(any(), any(), any()))
          .thenAnswer((_) async => null);

      await controller.signUp('Selma', 'selma@email.com', 'senha123');

      expect(controller.person.value, isNull);
      expect(capturedErrors, contains('Falha ao criar conta'));
      expect(controller.isLoading, isFalse);
    });

    test('signUp lança exceção captura erro', () async {
      when(() => mockRepository.signUp(any(), any(), any()))
          .thenThrow(Exception('erro inesperado'));

      await controller.signUp('Selma', 'selma@email.com', 'senha123');

      expect(controller.person.value, isNull);
      expect(capturedErrors.any((e) => e.contains('erro inesperado')), isTrue);
      expect(controller.isLoading, isFalse);
    });

    test('loginWithEmail atualiza user quando sucesso', () async {
      when(() => mockRepository.signIn('selma@email.com', 'senha123'))
          .thenAnswer((_) async => mockUser);

      final future = controller.loginWithEmail('selma@email.com', 'senha123');

      expect(controller.isLoading, isTrue);

      await future;

      expect(controller.person.value, equals(mockUser));
      expect(controller.isLoading, isFalse);
      verify(() => mockRepository.signIn('selma@email.com', 'senha123')).called(1);
    });

    test('loginWithEmail não atualiza user quando falha', () async {
      when(() => mockRepository.signIn(any(), any()))
          .thenAnswer((_) async => null);

      await controller.loginWithEmail('selma@email.com', 'senha123');

      expect(controller.person.value, isNull);
      expect(capturedErrors, contains('Credenciais inválidas'));
      expect(controller.isLoading, isFalse);
    });

    test('loginWithEmail lança exceção captura erro', () async {
      when(() => mockRepository.signIn(any(), any()))
          .thenThrow(Exception('falha de rede'));

      await controller.loginWithEmail('selma@email.com', 'senha123');

      expect(controller.person.value, isNull);
      expect(capturedErrors, contains('Falha ao fazer login'));
      expect(controller.isLoading, isFalse);
    });
test('isLoggedIn e user refletem corretamente o estado', () {
  expect(controller.isLoggedIn, isFalse);
  expect(controller.user, isNull);

  controller.person.value = mockUser;
  expect(controller.isLoggedIn, isTrue);
});
test('signUp captura FirebaseAuthException corretamente', () async {
  when(() => mockRepository.signUp(any(), any(), any()))
      .thenThrow(FirebaseAuthException(
    code: 'email-already-in-use',
    message: 'Email já cadastrado',
  ));

  await controller.signUp('Selma', 'selma@email.com', 'senha123');

  expect(capturedErrors, contains('Email já cadastrado'));
});test('loginWithEmail captura FirebaseAuthException corretamente', () async {
  when(() => mockRepository.signIn(any(), any()))
      .thenThrow(FirebaseAuthException(
    code: 'user-not-found',
    message: 'Usuário não encontrado',
  ));

  await controller.loginWithEmail('selma@email.com', 'senha123');

  expect(capturedErrors, contains('Falha ao fazer login'));
});




    test('signOut limpa user e chama repository', () async {
      controller.person.value = mockUser;
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      await controller.signOut();

      expect(controller.person.value, isNull);
      verify(() => mockRepository.signOut()).called(1);
    });
  });
}
