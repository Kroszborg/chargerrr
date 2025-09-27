import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/station_entity.dart';

class GetStationsParams {
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? searchQuery;
  final List<String>? connectorTypes;
  final double? maxPrice;
  final double? minRating;
  final bool? availableOnly;
  final String? sortBy;
  final int? limit;
  final int? offset;

  const GetStationsParams({
    this.latitude,
    this.longitude,
    this.radius,
    this.searchQuery,
    this.connectorTypes,
    this.maxPrice,
    this.minRating,
    this.availableOnly,
    this.sortBy,
    this.limit,
    this.offset,
  });

  GetStationsParams copyWith({
    double? latitude,
    double? longitude,
    double? radius,
    String? searchQuery,
    List<String>? connectorTypes,
    double? maxPrice,
    double? minRating,
    bool? availableOnly,
    String? sortBy,
    int? limit,
    int? offset,
  }) {
    return GetStationsParams(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      searchQuery: searchQuery ?? this.searchQuery,
      connectorTypes: connectorTypes ?? this.connectorTypes,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      availableOnly: availableOnly ?? this.availableOnly,
      sortBy: sortBy ?? this.sortBy,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

abstract class StationRepository {
  Future<Either<Failure, List<StationEntity>>> getStations(
    GetStationsParams params,
  );

  Future<Either<Failure, StationEntity>> getStationById(String id);

  Future<Either<Failure, List<StationEntity>>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    int limit = 20,
  });

  Future<Either<Failure, List<StationEntity>>> searchStations({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 20,
  });

  Future<Either<Failure, List<StationEntity>>> getFavoriteStations(
    List<String> stationIds,
  );

  Future<Either<Failure, void>> addToFavorites(String stationId);

  Future<Either<Failure, void>> removeFromFavorites(String stationId);

  Future<Either<Failure, bool>> isStationFavorite(String stationId);

  Stream<Either<Failure, List<StationEntity>>> getStationsStream(
    GetStationsParams params,
  );

  Future<Either<Failure, List<String>>> getConnectorTypes();

  Future<Either<Failure, List<String>>> getAmenities();

  Future<Either<Failure, void>> reportStation({
    required String stationId,
    required String reason,
    String? description,
  });

  Future<Either<Failure, void>> updateStationAvailability({
    required String stationId,
    required int availablePoints,
  });
}