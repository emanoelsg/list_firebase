// app/features/auth/presentation/controller/auth_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';
import 'package:list_firebase/app/features/auth/domain/auth_repository.dart';

/// The AuthController manages user authentication, including sign-up, sign-in, and sign-out.
/// It uses a reactive approach with GetX to update the UI based on state changes.
class AuthController extends GetxController with BaseState {
  final AuthRepository _repository;

  /// Private constructor to enforce dependency injection.
  AuthController({required AuthRepository repository}) : _repository = repository;

  /// Reactive variable to hold the authenticated user's data.
  final Rxn<UserEntity> person = Rxn<UserEntity>();

  /// Computed property to check if a user is currently logged in.
  bool get isLoggedIn => person.value != null;

  /// Fetches the current user data from the repository.
  /// This is typically called on app startup to restore the user session.
  Future<void> getCurrentUser() async {
    try {
      final user = await _repository.getCurrentUser();
      person.value = user;
    } catch (e) {
      // It's common to fail silently here as a lack of user data
      // is not an error but a state of being logged out.
      debugPrint('Failed to get current user: $e');
    }
  }

  /// Handles user sign-up with email and password.
  Future<void> signUp(String name, String email, String password) async {
    state.value = ControllerState.loading;
    try {
      final result = await _repository.signUp(name, email, password);
      if (result != null) {
        person.value = result;
        state.value = ControllerState.success;
      } else {
        errorMessage.value = 'Failed to create account. Please try again.';
        state.value = ControllerState.error;
      }
    } on FirebaseAuthException catch (e) {
      // Specific handling for Firebase Authentication errors.
      errorMessage.value = e.message ?? 'An unknown authentication error occurred.';
      state.value = ControllerState.error;
    } catch (e) {
      // Generic error handling for other exceptions.
      errorMessage.value = e.toString();
      state.value = ControllerState.error;
    } finally {
      _showSnackbarOnError();
    }
  }

  /// Handles user sign-in with email and password.
  Future<void> loginWithEmail(String email, String password) async {
    state.value = ControllerState.loading;
    try {
      final result = await _repository.signIn(email, password);
      if (result != null) {
        person.value = result;
        state.value = ControllerState.success;
      } else {
        errorMessage.value = 'Invalid credentials. Please check your email and password.';
        state.value = ControllerState.error;
      }
    } on FirebaseAuthException catch (e) {
      // Specific handling for Firebase Authentication errors.
      errorMessage.value = e.message ?? 'An unknown authentication error occurred.';
      state.value = ControllerState.error;
    } catch (e) {
      // Generic error handling.
      errorMessage.value = 'Failed to sign in. Please try again later.';
      state.value = ControllerState.error;
    } finally {
      _showSnackbarOnError();
    }
  }

  /// Signs out the current user and clears the local user data.
  Future<void> signOut() async {
    await _repository.signOut();
    person.value = null;
  }

  /// Private helper method to show a snackbar with the error message.
  void _showSnackbarOnError() {
    if (state.value == ControllerState.error) {
      // Só mostra snackbar se houver contexto de navegação (evita erro em teste)
      if (Get.context != null) {
        Get.snackbar(
          'Error',
          errorMessage.value ?? '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}