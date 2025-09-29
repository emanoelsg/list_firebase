// app/features/auth/data/auth_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // para debugPrint
import 'package:list_firebase/app/features/auth/domain/auth_repository.dart';
import 'package:list_firebase/app/features/auth/domain/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity?> signUp(String name, String email, String password) async {
    debugPrint("🔵 [AuthRepositoryImpl] signUp iniciado para $email");
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = credential.user?.uid;
      if (userId == null) {
        debugPrint("⚠️ [AuthRepositoryImpl] signUp falhou: userId é null");
        return null;
      }

      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ [AuthRepositoryImpl] signUp concluído para $email");
      return UserEntity(id: userId, email: email, name: name);
    } catch (e) {
      debugPrint("❌ [AuthRepositoryImpl] Erro no signUp: $e");
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    debugPrint("🔵 [AuthRepositoryImpl] signIn iniciado para $email");
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = credential.user?.uid;
      if (userId == null) {
        debugPrint("⚠️ [AuthRepositoryImpl] signIn falhou: userId é null");
        return null;
      }

      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      if (data == null) {
        debugPrint("⚠️ [AuthRepositoryImpl] signIn falhou: dados não encontrados no Firestore");
        return null;
      }

      debugPrint("✅ [AuthRepositoryImpl] signIn concluído para $email");
      return UserEntity(id: userId, email: email, name: data['name'] ?? '');
    } catch (e) {
      debugPrint("❌ [AuthRepositoryImpl] Erro no signIn: $e");
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    debugPrint("🔵 [AuthRepositoryImpl] signOut iniciado");
    try {
      await _auth.signOut();
      debugPrint("✅ [AuthRepositoryImpl] signOut concluído");
    } catch (e) {
      debugPrint("❌ [AuthRepositoryImpl] Erro no signOut: $e");
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    debugPrint("🔵 [AuthRepositoryImpl] getCurrentUser iniciado");
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint("⚠️ [AuthRepositoryImpl] Nenhum usuário logado");
        return null;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data == null) {
        debugPrint("⚠️ [AuthRepositoryImpl] Usuário logado mas sem dados no Firestore");
        return null;
      }

      debugPrint("✅ [AuthRepositoryImpl] getCurrentUser retornou ${user.email}");
      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        name: data['name'] ?? '',
      );
    } catch (e) {
      debugPrint("❌ [AuthRepositoryImpl] Erro no getCurrentUser: $e");
      rethrow;
    }
  }
}
