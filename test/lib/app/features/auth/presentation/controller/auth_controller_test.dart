// test/lib/app/features/auth/presentation/controller/auth_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';
import 'package:list_firebase/app/features/auth/domain/auth_repository.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';

// Mock classes for dependencies
class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

// We need a fake for a UserEntity
class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController controller;
  late MockAuthRepository mockRepository;

  final mockUserEntity = UserEntity(id: 'user1', email: 'test@mail.com', name: 'Test User');

  setUpAll(() {
    // Register the fallback value for any() calls with UserEntity
    registerFallbackValue(FakeUserEntity());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    controller = AuthController(repository: mockRepository);
    // Reset GetX instance for a clean test environment
    Get.reset();
  });

  group('AuthController', () {
    test('should return a valid user when login is successful', () async {
      // Arrange
      when(() => mockRepository.signIn(any(), any())).thenAnswer((_) async => mockUserEntity);

      // Act
      await controller.loginWithEmail('test@mail.com', 'password123');

      // Assert
      expect(controller.state.value, ControllerState.success);
      expect(controller.person.value, mockUserEntity);
      verify(() => mockRepository.signIn('test@mail.com', 'password123')).called(1);
    });

    test('should set state to loading and then to success on successful sign-up', () async {
      // Arrange
      when(() => mockRepository.signUp(any(), any(), any())).thenAnswer((_) async => mockUserEntity);
      
      // Act
      final future = controller.signUp('Test User', 'test@mail.com', 'password123');
      
      // Assert the initial state is loading
      expect(controller.state.value, ControllerState.loading);

      await future;

      // Assert the final state is success and user data is set
      expect(controller.state.value, ControllerState.success);
      expect(controller.person.value, mockUserEntity);
    });
    
    test('should handle invalid login credentials correctly', () async {
      // Arrange
      when(() => mockRepository.signIn(any(), any())).thenAnswer((_) async => null);

      // Act
      await controller.loginWithEmail('wrong@mail.com', 'wrongpass');

      // Assert
      expect(controller.state.value, ControllerState.error);
      expect(controller.errorMessage.value, 'Invalid credentials.');
      expect(controller.person.value, isNull);
    });
    
    test('should handle FirebaseAuthException on sign-in', () async {
      // Arrange
      when(() => mockRepository.signIn(any(), any()))
          .thenThrow(FirebaseAuthException(code: 'user-not-found', message: 'User not found.'));

      // Act
      await controller.loginWithEmail('nonexistent@mail.com', 'password123');
      
      // Assert
      expect(controller.state.value, ControllerState.error);
      expect(controller.errorMessage.value, 'User not found.');
      expect(controller.person.value, isNull);
    });
    
    test('should handle generic exceptions on sign-in', () async {
      // Arrange
      when(() => mockRepository.signIn(any(), any()))
          .thenThrow(Exception('Network connection failed.'));

      // Act
      await controller.loginWithEmail('test@mail.com', 'password123');
      
      // Assert
      expect(controller.state.value, ControllerState.error);
      expect(controller.errorMessage.value, 'Failed to sign in. Please try again later.');
      expect(controller.person.value, isNull);
    });

    test('should clear user data and sign out successfully', () async {
      // Arrange
      controller.person.value = mockUserEntity;
      when(() => mockRepository.signOut()).thenAnswer((_) async {});
      
      // Act
      await controller.signOut();
      
      // Assert
      expect(controller.person.value, isNull);
      verify(() => mockRepository.signOut()).called(1);
    });
  });
}