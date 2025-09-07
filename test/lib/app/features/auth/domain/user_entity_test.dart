import 'package:flutter_test/flutter_test.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('deve criar uma instância corretamente', () {
      final user = UserEntity(id: '1', email: 'teste@email.com', name: 'Nome');

      expect(user.id, '1');
      expect(user.email, 'teste@email.com');
      expect(user.name, 'Nome');
    });

    test('deve permitir criar sem name', () {
      final user = UserEntity(id: '2', email: 'teste2@email.com');

      expect(user.id, '2');
      expect(user.email, 'teste2@email.com');
      expect(user.name, null);
    });

    test('igualdade e hashCode', () {
      final user1 = UserEntity(id: '1', email: 'a@b.com', name: 'Alice');
      final user2 = UserEntity(id: '1', email: 'a@b.com', name: 'Alice');
      final user3 = UserEntity(id: '3', email: 'c@d.com', name: 'Bob');

      expect(user1, user2); // igualdade
      expect(user1.hashCode, user2.hashCode);

      expect(user1 == user3, false); // diferente
      expect(user1.hashCode == user3.hashCode, false);
    });
  });
}
