import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class SignInRequested extends AuthEvent {
  const SignInRequested();

  @override
  List<Object?> get props => [];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();

  @override
  List<Object?> get props => [];
}

class AuthStateChanged extends AuthEvent {
  final UserEntity? user;
  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}