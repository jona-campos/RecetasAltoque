import '../../repositories/auth_repository.dart';
import '../../entities/user.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  UserEntity? call() {
    return repository.getCurrentUser();
  }
}