import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../datasources/auth/auth_service.dart';
import '../../core/errors/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;

  AuthRepositoryImpl({required this.authService});

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      return await authService.signInWithGoogle();
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await authService.signOut();
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  UserEntity? getCurrentUser() {
    return authService.getCurrentUser();
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return authService.authStateChanges();
  }
}