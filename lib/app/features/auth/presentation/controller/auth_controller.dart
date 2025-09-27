// app/features/auth/presentation/controller/auth_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';
import 'package:list_firebase/app/features/auth/domain/auth_repository.dart';
import 'package:list_firebase/app/features/tasks/presentation/pages/tasks_page.dart';

class AuthController extends GetxController with BaseState {
  final AuthRepository _repository;

  AuthController({required AuthRepository repository}) : _repository = repository {
    debugPrint('[AuthController] Instanciado');
  }
 
  final Rxn<UserEntity> person = Rxn<UserEntity>();
  UserEntity? get currentUser => person.value;
  bool get isLoggedIn => person.value != null;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[AuthController] onInit chamado — buscando usuário atual...');
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    try {
      final user = await _repository.getCurrentUser();
      person.value = user;
      debugPrint('[AuthController] getCurrentUser -> ${user != null ? 'Usuário encontrado: ${user.uid}' : 'Nenhum usuário logado'}');
    } catch (e) {
      debugPrint('[AuthController] Erro ao buscar usuário atual: $e');
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    state.value = ControllerState.loading;
    try {
      final result = await _repository.signUp(name, email, password);
      if (result != null) {
        person.value = result;
        debugPrint('[AuthController] signUp -> Usuário criado: ${result.uid}');
Get.offAll(() => TasksPage(userId: currentUser!.uid));
        state.value = ControllerState.success;
      } else {
        errorMessage.value = 'Failed to create account. Please try again.';
        state.value = ControllerState.error;
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? 'Erro desconhecido no cadastro.';
      state.value = ControllerState.error;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = ControllerState.error;
    } finally {
      _showSnackbarOnError();
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    state.value = ControllerState.loading;
    try {
      final result = await _repository.signIn(email, password);
      if (result != null) {
        person.value = result;
        debugPrint('[AuthController] loginWithEmail -> Login bem-sucedido: ${result.uid}');
      Get.offAll(() => TasksPage(userId: currentUser!.uid));
        state.value = ControllerState.success;
      } else {
        errorMessage.value = 'Invalid credentials.';
        state.value = ControllerState.error;
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? 'Erro desconhecido no login.';
      state.value = ControllerState.error;
    } catch (e) {
      errorMessage.value = 'Failed to sign in. Please try again later.';
      state.value = ControllerState.error;
    } finally {
      _showSnackbarOnError();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    person.value = null;
    debugPrint('[AuthController] signOut -> Usuário desconectado');
  }

  void _showSnackbarOnError() {
    if (state.value == ControllerState.error) {
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
