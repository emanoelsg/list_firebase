// app/core/bindings/initial_binding.dart

import 'package:flutter/material.dart';
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
    debugPrint('[InitialBindings] Iniciando injeção de dependências...');

    // 1. Injetando repositórios
    debugPrint('[InitialBindings] Injetando AuthRepository');
    Get.put<AuthRepository>(AuthRepositoryImpl());

    debugPrint('[InitialBindings] Injetando TaskRepository');
    Get.put<TaskRepository>(TaskRepositoryImpl());

    // 2. Injetando serviços
    debugPrint('[InitialBindings] Injetando NotificationService');
    Get.put<NotificationService>(NotificationService());

    // 3. Injetando controladores
    debugPrint('[InitialBindings] Injetando NotificationController');
    Get.put<NotificationController>(
      NotificationController(service: Get.find()),
    );

    debugPrint('[InitialBindings] Injetando AuthController');
    Get.put<AuthController>(
      AuthController(repository: Get.find()),
    );

    debugPrint('[InitialBindings] Injetando TaskController');
    Get.put<TaskController>(
      TaskController(
        repository: Get.find(),
        notificationController: Get.find(),
      ),
    );

    debugPrint('[InitialBindings] Todas as dependências foram injetadas com sucesso!');
  }
}
