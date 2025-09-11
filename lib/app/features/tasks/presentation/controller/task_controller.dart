// app/features/tasks/presentation/controller/task_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/base/base_state.dart';
import 'package:list_firebase/app/features/notifications/controller/notification_controller.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';
import 'package:list_firebase/app/features/tasks/domain/task_repository.dart';
import 'package:uuid/uuid.dart';

class TaskController extends GetxController with BaseState<TaskController> {
  final TaskRepository _repository;
  final NotificationController _notificationController;

  TaskController({
    required TaskRepository repository,
    NotificationController? notificationController,
  })  : _repository = repository,
        _notificationController =
            notificationController ?? Get.find<NotificationController>();

  final tasks = <TaskEntity>[].obs;
  final message = RxnString();
  StreamSubscription<List<TaskEntity>>? _tasksSubscription;

  @visibleForTesting
  NotificationController get notificationController => _notificationController;

  /// Carrega todas as tarefas para um usuário específico
  void loadTasks(String userId) {
    isLoading.value = true;
    _tasksSubscription?.cancel();
    _tasksSubscription = _repository.watchTasks(userId).listen(
      (taskList) {
        tasks.value = taskList;
        error.value = '';
        isLoading.value = false;
      },
      onError: (e) {
        error.value = 'Error loading tasks: $e';
        isLoading.value = false;
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
  }) async {
    final task = TaskEntity(
      id: const Uuid().v4(),
      title: title,
      description: description,
      userId: userId,
      createdAt: DateTime.now(),
      repeatType: repeatType,
      weekDays: repeatType == 'weekly' ? weekDays : null,
      reminderTime: reminderTime,
    );

    try {
      isLoading.value = true;
      await _repository.addTask(userId, task);

      if (task.reminderTime != null) {
        await _notificationController.scheduleReminderForTask(task);
      }

      message.value = 'Task added successfully';
    } catch (e) {
      error.value = 'Error adding task: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza uma tarefa existente
  Future<void> updateTask(
    String userId,
    TaskEntity task, {
    String? repeatType,
    List<int>? weekDays,
    String? reminderTime,
  }) async {
    final updatedTask = task.copyWith(
      repeatType: repeatType,
      weekDays: repeatType == 'weekly' ? weekDays : null,
      reminderTime: reminderTime,
    );

    try {
      isLoading.value = true;
      await _repository.updateTask(userId, updatedTask);

      await _notificationController.cancelRemindersForTask(task);
      if (updatedTask.reminderTime != null) {
        await _notificationController.scheduleReminderForTask(updatedTask);
      }

      message.value = 'Task updated';
    } catch (e) {
      error.value = 'Error updating task: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Exclui uma tarefa
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      isLoading.value = true;
      final task = tasks.firstWhere((t) => t.id == taskId);

      await _repository.deleteTask(userId, taskId);
      await _notificationController.cancelRemindersForTask(task);

      message.value = 'Task deleted';
    } catch (e) {
      error.value = 'Error deleting task: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Alterna o estado de conclusão da tarefa
  Future<void> toggleTaskDone(
      String userId, TaskEntity task, bool isDone) async {
    final updatedTask = task.copyWith(isDone: isDone);
    await updateTask(userId, updatedTask);
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    super.onClose();
  }
}
