import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/station_entity.dart';
import '../../domain/repositories/station_repository.dart';
import '../datasources/station_remote_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class StationRepositoryImpl implements StationRepository {
  final StationRemoteDataSource remoteDataSource;
  final AuthRemoteDataSource authDataSource;
  final NetworkInfo networkInfo;

  StationRepositoryImpl({
    required this.remoteDataSource,
    required this.authDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<StationEntity>>> getStations(
    GetStationsParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final stations = await remoteDataSource.getStations(params);
        return Right(stations);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get stations: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, StationEntity>> getStationById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final station = await remoteDataSource.getStationById(id);
        return Right(station);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get station: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<StationEntity>>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final stations = await remoteDataSource.getNearbyStations(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          limit: limit,
        );
        return Right(stations);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get nearby stations: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<StationEntity>>> searchStations({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final stations = await remoteDataSource.searchStations(
          query: query,
          latitude: latitude,
          longitude: longitude,
          limit: limit,
        );
        return Right(stations);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to search stations: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<StationEntity>>> getFavoriteStations(
    List<String> stationIds,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final stations = await remoteDataSource.getFavoriteStations(stationIds);
        return Right(stations);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get favorite stations: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(String stationId) async {
    if (await networkInfo.isConnected) {
      try {
        final currentUser = await authDataSource.getCurrentUser();
        if (currentUser == null) {
          return const Left(AuthFailure(message: 'User not signed in'));
        }

        final updatedFavorites = List<String>.from(currentUser.favoriteStations);
        if (!updatedFavorites.contains(stationId)) {
          updatedFavorites.add(stationId);
          await authDataSource.updateUserProfile(fullName: currentUser.fullName);
        }

        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to add to favorites: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String stationId) async {
    if (await networkInfo.isConnected) {
      try {
        final currentUser = await authDataSource.getCurrentUser();
        if (currentUser == null) {
          return const Left(AuthFailure(message: 'User not signed in'));
        }

        final updatedFavorites = List<String>.from(currentUser.favoriteStations);
        updatedFavorites.remove(stationId);
        await authDataSource.updateUserProfile(fullName: currentUser.fullName);

        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to remove from favorites: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> isStationFavorite(String stationId) async {
    try {
      final currentUser = await authDataSource.getCurrentUser();
      if (currentUser == null) {
        return const Right(false);
      }

      final isFavorite = currentUser.favoriteStations.contains(stationId);
      return Right(isFavorite);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure(message: 'Failed to check favorite status: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<StationEntity>>> getStationsStream(
    GetStationsParams params,
  ) async* {
    try {
      await for (final stations in remoteDataSource.getStationsStream(params)) {
        yield Right(stations);
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      yield Left(ServerFailure(message: 'Failed to get stations stream: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getConnectorTypes() async {
    if (await networkInfo.isConnected) {
      try {
        final connectorTypes = await remoteDataSource.getConnectorTypes();
        return Right(connectorTypes);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get connector types: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAmenities() async {
    if (await networkInfo.isConnected) {
      try {
        final amenities = await remoteDataSource.getAmenities();
        return Right(amenities);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get amenities: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> reportStation({
    required String stationId,
    required String reason,
    String? description,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.reportStation(
          stationId: stationId,
          reason: reason,
          description: description,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to report station: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> updateStationAvailability({
    required String stationId,
    required int availablePoints,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateStationAvailability(
          stationId: stationId,
          availablePoints: availablePoints,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to update station availability: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}