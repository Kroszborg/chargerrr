import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class AuthenticateUserParams {
  final String email;
  final String password;

  const AuthenticateUserParams({
    required this.email,
    required this.password,
  });
}

class SignUpUserParams {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;

  const SignUpUserParams({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });
}

class UpdateUserProfileParams {
  final String? fullName;
  final String? phoneNumber;
  final String? profileImageUrl;

  const UpdateUserProfileParams({
    this.fullName,
    this.phoneNumber,
    this.profileImageUrl,
  });
}

class AuthenticateUser {
  final AuthRepository repository;

  AuthenticateUser({required this.repository});

  Future<Either<Failure, UserEntity>> signIn(AuthenticateUserParams params) {
    return repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }

  Future<Either<Failure, UserEntity>> signUp(SignUpUserParams params) {
    return repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
    );
  }

  Future<Either<Failure, void>> signOut() {
    return repository.signOut();
  }

  Future<Either<Failure, void>> sendPasswordResetEmail(String email) {
    return repository.sendPasswordResetEmail(email: email);
  }

  Future<Either<Failure, UserEntity?>> getCurrentUser() {
    return repository.getCurrentUser();
  }

  Future<Either<Failure, bool>> isUserSignedIn() {
    return repository.isUserSignedIn();
  }

  Stream<Either<Failure, UserEntity?>> get authStateChanges {
    return repository.authStateChanges;
  }

  Future<Either<Failure, UserEntity>> updateUserProfile(
    UpdateUserProfileParams params,
  ) {
    return repository.updateUserProfile(
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
      profileImageUrl: params.profileImageUrl,
    );
  }

  Future<Either<Failure, void>> deleteAccount() {
    return repository.deleteAccount();
  }

  Future<Either<Failure, void>> sendEmailVerification() {
    return repository.sendEmailVerification();
  }

  Future<Either<Failure, void>> reloadUser() {
    return repository.reloadUser();
  }
}