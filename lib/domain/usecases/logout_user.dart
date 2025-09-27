import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUser {
  final AuthRepository repository;

  LogoutUser({required this.repository});

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}