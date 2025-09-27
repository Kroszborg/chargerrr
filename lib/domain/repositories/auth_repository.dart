import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, bool>> isUserSignedIn();

  Stream<Either<Failure, UserEntity?>> get authStateChanges;

  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  });

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, void>> reloadUser();
}