// app/features/tasks/presentation/controller/task_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';
import 'package:list_firebase/app/features/tasks/domain/task_repository.dart';
import 'package:uuid/uuid.dart';

// Enum para gerenciar os estados da tela de forma clara
enum TaskControllerState { idle, loading, success, error }

class TaskController extends GetxController {
  final TaskRepository _repository;
  final NotificationController _notificationController;

  TaskController({
    required TaskRepository repository,
    required NotificationController notificationController,
  })  : _repository = repository,
        _notificationController = notificationController;

  final tasks = <TaskEntity>[].obs;
  final state = TaskControllerState.idle.obs;
  final errorMessage = RxnString();
  final message = RxnString();

  StreamSubscription<List<TaskEntity>>? _tasksSubscription;

  @visibleForTesting
  NotificationController get notificationController => _notificationController;

  /// Carrega todas as tarefas para um usuário específico
  void loadTasks(String userId) {
    state.value = TaskControllerState.loading;
    _tasksSubscription?.cancel();
    _tasksSubscription = _repository.watchTasks(userId).listen(
      (taskList) {
        tasks.value = taskList;
        state.value = TaskControllerState.success;
      },
      onError: (e) {
        errorMessage.value = 'Erro ao carregar tarefas: $e';
        state.value = TaskControllerState.error;
        if (kDebugMode) {
          print(e);
        }
      },
    );
  }

  /// Adiciona uma nova tarefa
  Future<void> addTask(
    String userId,
    String title,
    String description, {
    String? repeatType,
    List<int>? weekDays,
    String? reminderTime,
    DateTime? reminderAt,
  }) async {
    try {
      state.value = TaskControllerState.loading;
      final task = TaskEntity(
        id: const Uuid().v4(),
        title: title,
        description: description,
        userId: userId,
        createdAt: DateTime.now(),
        repeatType: repeatType,
        weekDays: repeatType == 'weekly' ? weekDays : null,
        reminderTime: reminderTime,
        reminderAt: reminderAt,
      );

      await _repository.addTask(userId, task);
      await _notificationController.scheduleReminderForTask(task);

      message.value = 'Tarefa adicionada com sucesso!';
      state.value = TaskControllerState.success;
    } catch (e) {
      errorMessage.value = 'Erro ao adicionar tarefa: $e';
      state.value = TaskControllerState.error;
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Atualiza uma tarefa existente
  Future<void> updateTask(
    String userId,
    TaskEntity task, {
    String? newTitle,
    String? newDescription,
    bool? newIsDone,
    String? repeatType,
    List<int>? weekDays,
    String? reminderTime,
    DateTime? reminderAt,
  }) async {
    try {
      state.value = TaskControllerState.loading;
      final updatedTask = task.copyWith(
        title: newTitle,
        description: newDescription,
        isDone: newIsDone,
        repeatType: repeatType,
        weekDays: repeatType == 'weekly' ? weekDays : null,
        reminderTime: reminderTime,
        reminderAt: reminderAt,
      );

      await _repository.updateTask(userId, updatedTask);
      await _notificationController.cancelRemindersForTask(task);
      await _notificationController.scheduleReminderForTask(updatedTask);

      message.value = 'Tarefa atualizada!';
      state.value = TaskControllerState.success;
    } catch (e) {
      errorMessage.value = 'Erro ao atualizar tarefa: $e';
      state.value = TaskControllerState.error;
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Exclui uma tarefa
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      state.value = TaskControllerState.loading;
      final task = tasks.firstWhere((t) => t.id == taskId);

      await _repository.deleteTask(userId, taskId);
      await _notificationController.cancelRemindersForTask(task);

      message.value = 'Tarefa excluída!';
      state.value = TaskControllerState.success;
    } catch (e) {
      errorMessage.value = 'Erro ao excluir tarefa: $e';
      state.value = TaskControllerState.error;
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Alterna o estado de conclusão da tarefa
  Future<void> toggleTaskDone(String userId, TaskEntity task) async {
    try {
      final updatedTask = task.copyWith(isDone: !task.isDone);
      await _repository.updateTask(userId, updatedTask);
    } catch (e) {
      errorMessage.value = 'Erro ao alternar status da tarefa: $e';
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    super.onClose();
  }
}