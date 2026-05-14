import 'package:cineverse/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
  Future<UserEntity?> signInWithGoogle();
  Future<UserEntity?> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity?> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}
