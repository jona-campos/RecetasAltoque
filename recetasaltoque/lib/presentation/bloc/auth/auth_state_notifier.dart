import 'package:flutter/foundation.dart';
import '../../../domain/repositories/auth_repository.dart';

class AuthStateNotifier extends ChangeNotifier {
  final AuthRepository authRepository;
  bool _isLoggedIn = false;

  AuthStateNotifier(this.authRepository) {
    _isLoggedIn = authRepository.getCurrentUser() != null;
    authRepository.authStateChanges().listen((user) {
      _isLoggedIn = user != null;
      notifyListeners();
    });
  }

  bool get isLoggedIn => _isLoggedIn;
}