import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/tasks/presentation/controller/task_controller.dart';
import 'package:list_firebase/app/features/tasks/presentation/widgets/addtask_page.dart';
import 'package:mocktail/mocktail.dart';

// Mock do TaskController
class MockTaskController extends Mock implements TaskController {}

void main() {
  late MockTaskController mockTaskController;

  setUp(() {
    mockTaskController = MockTaskController();

    // Limpa os controllers antes de cada teste
    Get.reset();

    // Injeta o mock com lazyPut para não chamar onStart
    Get.lazyPut<TaskController>(() => mockTaskController);
  });

  testWidgets('Adicionar nova task', (WidgetTester tester) async {
    when(() => mockTaskController.addTask(
          any(),
          any(),
          any(),
          repeatType: any(named: 'repeatType'),
          weekDays: any(named: 'weekDays'),
          reminderTime: any(named: 'reminderTime'),
        )).thenAnswer((_) async {});

    const userId = 'user123';

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) {
            // Passa o argumento simulando Get.arguments
            return AddTaskPage( existingTask: null,
      testUserId: 'user123',);
          },
        ),
      ),
    );

    // Configura o Get.arguments para o builder
    Get.testMode = true; // evita dependências de rotas reais
  

    await tester.pumpAndSettle();

    // Preenche título e descrição
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Task');
    await tester.enterText(find.byType(TextFormField).at(1), 'Descrição teste');

    // Pressiona o botão de salvar
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    // Verifica se addTask foi chamado
    verify(() => mockTaskController.addTask(
          userId,
          'Test Task',
          'Descrição teste',
          repeatType: 'daily',
          weekDays: null,
          reminderTime: null,
        )).called(1);
  });
}
