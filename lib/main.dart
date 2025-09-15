// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;

// App imports
import 'package:list_firebase/firebase_options.dart';
import 'package:list_firebase/app/features/auth/data/auth_repository_impl.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
import 'package:list_firebase/app/features/notifications/service/notifications_service.dart';
import 'package:list_firebase/app/features/tasks/data/task_repository_impl.dart';
import 'package:list_firebase/app/features/tasks/presentation/controller/task_controller.dart';
import 'package:list_firebase/app/utils/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();

  // Serviços
  final taskRepository = TaskRepositoryImpl();
  final authRepository = AuthRepositoryImpl();
  final notificationService = NotificationService();
  await notificationService.init();

  // Primeiro registra NotificationController
  final notificationController = Get.put(
    NotificationController(service: notificationService),
  );

  Get.put(TaskController(
    repository: taskRepository,
    notificationController: notificationController,
  ));

  Get.put(AuthController(repository: authRepository));

  runApp(const ListTarefa());
}

class ListTarefa extends StatelessWidget {
  const ListTarefa({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      debugShowCheckedModeBanner: false,
    );
  }
}
