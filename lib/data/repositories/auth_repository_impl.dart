import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signInWithEmailAndPassword(
          email,
          password,
        );
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(AuthFailure(message: 'Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signUpWithEmailAndPassword(
          email,
          password,
          fullName,
          phoneNumber,
        );
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(AuthFailure(message: 'Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure(message: 'Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendPasswordResetEmail(email);
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(AuthFailure(message: 'Password reset failed: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure(message: 'Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserSignedIn() async {
    try {
      final isSignedIn = await remoteDataSource.isUserSignedIn();
      return Right(isSignedIn);
    } catch (e) {
      return Left(AuthFailure(message: 'Failed to check sign in status: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, UserEntity?>> get authStateChanges {
    try {
      return remoteDataSource.authStateChanges.map(
        (user) => Right<Failure, UserEntity?>(user),
      );
    } catch (e) {
      return Stream.value(
        Left(AuthFailure(message: 'Auth state changes failed: ${e.toString()}')),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.updateUserProfile(
          fullName: fullName,
          phoneNumber: phoneNumber,
          profileImageUrl: profileImageUrl,
        );
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(AuthFailure(message: 'Profile update failed: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAccount();
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(AuthFailure(message: 'Account deletion failed: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendEmailVerification();
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(AuthFailure(message: 'Email verification failed: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> reloadUser() async {
    try {
      await remoteDataSource.reloadUser();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure(message: 'User reload failed: ${e.toString()}'));
    }
  }
}