import 'package:flutter_test/flutter_test.dart';
import 'package:list_firebase/app/features/notifications/utils/notification_helper.dart';
import 'package:list_firebase/app/features/tasks/domain/task_entity.dart';

void main() {
  group('NotificationHelper', () {
    final task = TaskEntity(
      id: 'task123',
      title: 'Test Task',
      userId: 'user1',
      createdAt: DateTime.now(),
    );

    test('baseId retorna hashCode do id da task', () {
      final id = NotificationHelper.baseId(task);
      expect(id, task.id.hashCode);
    });

    test('weeklyId retorna hashCode somado com o dia da semana', () {
      for (var weekday = 1; weekday <= 7; weekday++) {
        final weeklyId = NotificationHelper.weeklyId(task, weekday);
        expect(weeklyId, task.id.hashCode + weekday);
      }
    });

    test('formatDate formata corretamente a data', () {
      final date = DateTime(2025, 9, 7, 8, 5); // 7/9 às 08:05
      final formatted = NotificationHelper.formatDate(date);
      expect(formatted, '7/9 às 08:05');
    });

    test('formatDate com minutos e horas com dois dígitos', () {
      final date = DateTime(2025, 12, 15, 14, 30);
      final formatted = NotificationHelper.formatDate(date);
      expect(formatted, '15/12 às 14:30');
    });
  });
}
