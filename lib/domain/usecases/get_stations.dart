import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/station_entity.dart';
import '../repositories/station_repository.dart';

class GetStations {
  final StationRepository repository;

  GetStations({required this.repository});

  Future<Either<Failure, List<StationEntity>>> call(
    GetStationsParams params,
  ) {
    return repository.getStations(params);
  }

  Future<Either<Failure, StationEntity>> getById(String id) {
    return repository.getStationById(id);
  }

  Future<Either<Failure, List<StationEntity>>> getNearby({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    int limit = 20,
  }) {
    return repository.getNearbyStations(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      limit: limit,
    );
  }

  Future<Either<Failure, List<StationEntity>>> search({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 20,
  }) {
    return repository.searchStations(
      query: query,
      latitude: latitude,
      longitude: longitude,
      limit: limit,
    );
  }

  Future<Either<Failure, List<StationEntity>>> getFavorites(
    List<String> stationIds,
  ) {
    return repository.getFavoriteStations(stationIds);
  }

  Stream<Either<Failure, List<StationEntity>>> getStationsStream(
    GetStationsParams params,
  ) {
    return repository.getStationsStream(params);
  }

  Future<Either<Failure, List<String>>> getConnectorTypes() {
    return repository.getConnectorTypes();
  }

  Future<Either<Failure, List<String>>> getAmenities() {
    return repository.getAmenities();
  }
}