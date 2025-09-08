// test/lib/app/features/auth/data/auth_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:list_firebase/app/features/auth/data/auth_repository_impl.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    // Configura Firebase Auth fake
    mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'uid123', email: 'test@email.com'),
    );

    // Configura Firestore fake
    fakeFirestore = FakeFirebaseFirestore();

    repository = AuthRepositoryImpl(
      auth: mockAuth,
      firestore: fakeFirestore,
    );
  });

  tearDown(() {
    // Reseta usuários fake
    mockAuth.signOut();
  });

test('signUp cria usuário no Firestore e retorna UserEntity', () async {
  final user = await repository.signUp('Test User', 'test@email.com', '123456');

  final expectedUid = mockAuth.currentUser!.uid; // pega o UID gerado

  expect(user, isNotNull);
  expect(user, isA<UserEntity>());
  expect(user?.id, expectedUid); // usa UID correto
  expect(user?.email, 'test@email.com');
  expect(user?.name, 'Test User');

  // Verifica se o documento realmente existe no Firestore fake
  final doc = await fakeFirestore.collection('users').doc(expectedUid).get();
  expect(doc.exists, true);
  expect(doc.data()?['name'], 'Test User');
});

  test('signIn retorna UserEntity se usuário existir', () async {
    // Primeiro adiciona o usuário no Firestore fake
    await fakeFirestore.collection('users').doc('uid123').set({'name': 'Test User'});

    final user = await repository.signIn('test@email.com', '123456');

    expect(user, isNotNull);
    expect(user?.id, 'uid123');
    expect(user?.email, 'test@email.com');
    expect(user?.name, 'Test User');
  });

  test('getCurrentUser retorna usuário existente', () async {
    // Adiciona no Firestore fake
    await fakeFirestore.collection('users').doc('uid123').set({'name': 'Test User'});

    final user = await repository.getCurrentUser();

    expect(user, isNotNull);
    expect(user?.id, 'uid123');
    expect(user?.email, 'test@email.com');
    expect(user?.name, 'Test User');
  });

  test('signOut chama auth.signOut sem erros', () async {
    await repository.signOut();

    // Garantia de que usuário foi deslogado
    expect(mockAuth.currentUser, isNull);
  });
}
