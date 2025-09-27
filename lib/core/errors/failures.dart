import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required String message,
    this.statusCode,
  }) : super(message: message);

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

class AuthFailure extends Failure {
  final String? code;

  const AuthFailure({
    required String message,
    this.code,
  }) : super(message: message);

  @override
  List<Object> get props => [message, code ?? ''];
}

class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({
    required String message,
    this.errors,
  }) : super(message: message);

  @override
  List<Object> get props => [message, errors ?? {}];
}

class LocationFailure extends Failure {
  const LocationFailure({required String message}) : super(message: message);
}

class PermissionFailure extends Failure {
  const PermissionFailure({required String message}) : super(message: message);
}