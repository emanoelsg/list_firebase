// app/features/auth/presentation/pages/splash/splash_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/pages/login/login_page.dart';
import 'package:list_firebase/app/features/tasks/presentation/pages/tasks_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We don't need a StatefulWidget here, as we're just listening to a reactive variable.
    final authController = Get.find<AuthController>();

    // `once` listens to a variable and executes a function only once when the value changes.
    once(authController.person, (UserEntity? user) {
      if (user != null) {
        // Navigate to the Tasks page if the user is not null
        Get.offAll(() => TasksPage(userId: user.uid));
      } else {
        // Navigate to the Login page if the user is null
        Get.offAll(() => const LoginPage());
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}