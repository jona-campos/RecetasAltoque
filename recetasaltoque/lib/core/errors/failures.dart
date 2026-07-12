import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class TranslationFailure extends Failure {
  const TranslationFailure({
    required super.message,
    super.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  @override
  List<Object?> get props => [message, code];
}
