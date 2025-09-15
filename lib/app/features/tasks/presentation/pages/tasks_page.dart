// app/features/tasks/presentation/pages/tasks_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:list_firebase/app/core/utils/constants/colors.dart';
import 'package:list_firebase/app/core/utils/constants/sizes.dart';
import 'package:list_firebase/app/features/tasks/presentation/controller/task_controller.dart';
import 'package:list_firebase/app/features/tasks/presentation/widgets/addtask_page.dart';

/// A página principal que exibe a lista de tarefas para um usuário.
class TasksPage extends StatefulWidget {
  final String userId;
  const TasksPage({super.key, required this.userId});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // Acesso ao controlador de tarefas usando Get.find
  late final TaskController controller;
  late final String userId;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TaskController>();
    userId = widget.userId;
    // Carrega as tarefas do usuário assim que a página é inicializada
    controller.loadTasks(userId);
  }

  /// Exibe um snackbar para mensagens de sucesso ou erro.
  void _showSnackbar(String message, Color backgroundColor) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Aviso',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor,
        colorText: TColors.textWhite,
        margin: const EdgeInsets.all(TSizes.md),
        borderRadius: TSizes.borderRadiusMd,
      );
      // Limpa a mensagem após exibir
      controller.message.value = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        centerTitle: true,
        backgroundColor: TColors.primary,
        foregroundColor: TColors.textWhite,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddTaskPage()),
        backgroundColor: TColors.accent,
        elevation: 6,
        child: const Icon(Icons.add, color: TColors.textWhite),
      ),
      body: Obx(() {
        // Exibe a mensagem de sucesso
        if (controller.message.value != null && controller.message.value!.isNotEmpty) {
          _showSnackbar(controller.message.value!, TColors.success);
        }

        // Usa um 'switch' para lidar com os diferentes estados do controlador
        switch (controller.state.value) {
          case TaskControllerState.loading:
            return const Center(
              child: CircularProgressIndicator(color: TColors.primary),
            );

          case TaskControllerState.error:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.errorMessage.value ?? 'Erro desconhecido'),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  ElevatedButton(
                    onPressed: () => controller.loadTasks(userId),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );

          case TaskControllerState.success:
          case TaskControllerState.idle:
            if (controller.tasks.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhuma tarefa encontrada. Clique no "+" para adicionar uma.',
                  style: TextStyle(fontSize: TSizes.fontSizeMd),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(TSizes.md),
              child: ListView.separated(
                itemCount: controller.tasks.length,
                separatorBuilder: (_, _) => const SizedBox(height: TSizes.sm),
                itemBuilder: (context, index) {
                  final task = controller.tasks[index];

                  return Slidable(
                    key: ValueKey(task.id),
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => Get.to(() => AddTaskPage(existingTask: task)),
                          backgroundColor: TColors.primary,
                          foregroundColor: TColors.textWhite,
                          icon: Icons.edit,
                          label: 'Editar',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => controller.deleteTask(userId, task.id),
                          backgroundColor: TColors.error,
                          foregroundColor: TColors.textWhite,
                          icon: Icons.delete_outline,
                          label: 'Excluir',
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(TSizes.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Checkbox para marcar a tarefa como concluída
                            Checkbox(
                              value: task.isDone,
                              activeColor: TColors.primary,
                              onChanged: (value) {
                                controller.toggleTaskDone(userId, task);
                              },
                            ),
                            const SizedBox(width: TSizes.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: TSizes.fontSizeLg,
                                      decoration: task.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (task.description != null && task.description!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        task.description!,
                                        style: const TextStyle(
                                          fontSize: TSizes.fontSizeSm,
                                          color: TColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  if (task.reminderTime != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Lembrete: ${task.reminderTime} (${task.repeatType})',
                                        style: const TextStyle(
                                          fontSize: TSizes.fontSizeLg,
                                          color: TColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
      }),
    );
  }
}