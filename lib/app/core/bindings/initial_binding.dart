// app/core/bindings/initial_binding.dart

import 'package:get/get.dart';
import 'package:list_firebase/app/features/auth/domain/auth_repository.dart';
import 'package:list_firebase/app/features/auth/data/auth_repository_impl.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
import 'package:list_firebase/app/features/notifications/service/notifications_service.dart';
import 'package:list_firebase/app/features/tasks/data/task_repository_impl.dart';
import 'package:list_firebase/app/features/tasks/domain/task_repository.dart';
import 'package:list_firebase/app/features/tasks/presentation/controller/task_controller.dart';

class InitialBindings implements Bindings {
  @override
  void dependencies() {
    // 1. Injetando a camada de dados (repositórios).
    // Esses não têm dependências e são a base.
    Get.put<AuthRepository>(AuthRepositoryImpl());
    Get.put<TaskRepository>(TaskRepositoryImpl());

    // 2. Injetando serviços de baixo nível.
    // Eles podem ser usados por controladores.
    Get.put<NotificationService>(NotificationService());

    // 3. Injetando a camada de apresentação (controladores).
    // Eles usam as dependências injetadas acima.
    Get.put<NotificationController>(
      NotificationController(service: Get.find()),
    );
    Get.put<AuthController>(
      AuthController(repository: Get.find()),
    );
    Get.put<TaskController>(
      TaskController(
        repository: Get.find(),
        notificationController: Get.find(),
      ),
    );
  }
}