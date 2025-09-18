// app/features/auth/presentation/pages/splash/splash_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/pages/login/login_page.dart';
import 'package:list_firebase/app/features/tasks/presentation/pages/tasks_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    debugPrint('[SplashPage] build chamado');

    return Obx(() {
      final user = authController.person.value;
      debugPrint('[SplashPage] Obx disparado → user: $user');

      if (user != null) {
        debugPrint('[SplashPage] Usuário autenticado → navegando para TasksPage');
        Future.microtask(() => Get.offAll(() => TasksPage(userId: user.uid)));
      } else {
        debugPrint('[SplashPage] Nenhum usuário autenticado → navegando para LoginPage');
        Future.microtask(() => Get.offAll(() => const LoginPage()));
      }

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
  }
}
