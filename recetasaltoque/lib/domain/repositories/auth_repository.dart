import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
  UserEntity? getCurrentUser();
  Stream<UserEntity?> authStateChanges();
}