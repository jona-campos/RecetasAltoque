import '../../repositories/auth_repository.dart';
import '../../entities/user.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<UserEntity> call() {
    return repository.signInWithGoogle();
  }
}