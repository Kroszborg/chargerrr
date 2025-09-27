import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/app_utils.dart';
import '../../domain/repositories/station_repository.dart';
import '../models/station_model.dart';

abstract class StationRemoteDataSource {
  Future<List<StationModel>> getStations(GetStationsParams params);
  Future<StationModel> getStationById(String id);
  Future<List<StationModel>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    int limit = 20,
  });
  Future<List<StationModel>> searchStations({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 20,
  });
  Future<List<StationModel>> getFavoriteStations(List<String> stationIds);
  Stream<List<StationModel>> getStationsStream(GetStationsParams params);
  Future<List<String>> getConnectorTypes();
  Future<List<String>> getAmenities();
  Future<void> reportStation({
    required String stationId,
    required String reason,
    String? description,
  });
  Future<void> updateStationAvailability({
    required String stationId,
    required int availablePoints,
  });
}

class StationRemoteDataSourceImpl implements StationRemoteDataSource {
  final FirebaseFirestore firestore;

  StationRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<StationModel>> getStations(GetStationsParams params) async {
    try {
      Query query = firestore.collection(ApiConstants.stationsCollection);

      if (params.availableOnly == true) {
        query = query.where('available_points', isGreaterThan: 0);
        query = query.where('is_operational', isEqualTo: true);
      }

      if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
        query = query.where('name', isGreaterThanOrEqualTo: params.searchQuery);
        query = query.where('name', isLessThan: params.searchQuery! + 'z');
      }

      if (params.connectorTypes != null && params.connectorTypes!.isNotEmpty) {
        query = query.where('connector_types', arrayContainsAny: params.connectorTypes);
      }

      if (params.maxPrice != null) {
        query = query.where('price_per_unit', isLessThanOrEqualTo: params.maxPrice);
      }

      if (params.minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: params.minRating);
      }

      if (params.sortBy != null) {
        switch (params.sortBy) {
          case 'distance':
            break;
          case 'price':
            query = query.orderBy('price_per_unit');
            break;
          case 'rating':
            query = query.orderBy('rating', descending: true);
            break;
          case 'name':
            query = query.orderBy('name');
            break;
          default:
            query = query.orderBy('updated_at', descending: true);
        }
      } else {
        query = query.orderBy('updated_at', descending: true);
      }

      if (params.limit != null) {
        query = query.limit(params.limit!);
      } else {
        query = query.limit(ApiConstants.defaultPageSize);
      }

      if (params.offset != null && params.offset! > 0) {
        final offsetQuery = await firestore
            .collection(ApiConstants.stationsCollection)
            .limit(params.offset!)
            .get();
        if (offsetQuery.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetQuery.docs.last);
        }
      }

      final querySnapshot = await query.get();
      var stations = querySnapshot.docs
          .map((doc) => StationModel.fromFirestore(doc))
          .toList();

      if (params.latitude != null && params.longitude != null) {
        stations = stations.map((station) {
          final distance = AppUtils.calculateDistance(
            params.latitude!,
            params.longitude!,
            station.latitude,
            station.longitude,
          );
          return station.copyWith(distance: distance);
        }).toList();

        if (params.radius != null) {
          stations = stations
              .where((station) => station.distance! <= params.radius!)
              .toList();
        }

        if (params.sortBy == 'distance' || params.sortBy == null) {
          stations.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
        }
      }

      return stations;
    } catch (e) {
      throw ServerException(message: 'Failed to get stations: ${e.toString()}');
    }
  }

  @override
  Future<StationModel> getStationById(String id) async {
    try {
      final doc = await firestore
          .collection(ApiConstants.stationsCollection)
          .doc(id)
          .get();

      if (!doc.exists) {
        throw const ServerException(message: 'Station not found');
      }

      return StationModel.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to get station: ${e.toString()}');
    }
  }

  @override
  Future<List<StationModel>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    int limit = 20,
  }) async {
    try {
      final params = GetStationsParams(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        limit: limit,
        sortBy: 'distance',
        availableOnly: true,
      );

      return await getStations(params);
    } catch (e) {
      throw ServerException(message: 'Failed to get nearby stations: ${e.toString()}');
    }
  }

  @override
  Future<List<StationModel>> searchStations({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 20,
  }) async {
    try {
      var firestoreQuery = firestore.collection(ApiConstants.stationsCollection);

      firestoreQuery = firestoreQuery.where('name', isGreaterThanOrEqualTo: query);
      firestoreQuery = firestoreQuery.where('name', isLessThan: query + 'z');
      firestoreQuery = firestoreQuery.limit(limit);

      final querySnapshot = await firestoreQuery.get();
      var stations = querySnapshot.docs
          .map((doc) => StationModel.fromFirestore(doc))
          .toList();

      final addressQuery = firestore.collection(ApiConstants.stationsCollection)
          .where('address', isGreaterThanOrEqualTo: query)
          .where('address', isLessThan: query + 'z')
          .limit(limit);

      final addressSnapshot = await addressQuery.get();
      final addressStations = addressSnapshot.docs
          .map((doc) => StationModel.fromFirestore(doc))
          .toList();

      final Set<String> stationIds = stations.map((s) => s.id).toSet();
      for (final station in addressStations) {
        if (!stationIds.contains(station.id)) {
          stations.add(station);
        }
      }

      if (latitude != null && longitude != null) {
        stations = stations.map((station) {
          final distance = AppUtils.calculateDistance(
            latitude,
            longitude,
            station.latitude,
            station.longitude,
          );
          return station.copyWith(distance: distance);
        }).toList();

        stations.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
      }

      return stations.take(limit).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search stations: ${e.toString()}');
    }
  }

  @override
  Future<List<StationModel>> getFavoriteStations(List<String> stationIds) async {
    try {
      if (stationIds.isEmpty) return [];

      final batches = <Future<List<StationModel>>>[];
      const batchSize = 10;

      for (int i = 0; i < stationIds.length; i += batchSize) {
        final batchIds = stationIds.skip(i).take(batchSize).toList();
        final batch = firestore
            .collection(ApiConstants.stationsCollection)
            .where(FieldPath.documentId, whereIn: batchIds)
            .get()
            .then((snapshot) => snapshot.docs
                .map((doc) => StationModel.fromFirestore(doc))
                .toList());
        batches.add(batch);
      }

      final results = await Future.wait(batches);
      return results.expand((batch) => batch).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get favorite stations: ${e.toString()}');
    }
  }

  @override
  Stream<List<StationModel>> getStationsStream(GetStationsParams params) {
    try {
      Query query = firestore.collection(ApiConstants.stationsCollection);

      if (params.availableOnly == true) {
        query = query.where('available_points', isGreaterThan: 0);
        query = query.where('is_operational', isEqualTo: true);
      }

      if (params.connectorTypes != null && params.connectorTypes!.isNotEmpty) {
        query = query.where('connector_types', arrayContainsAny: params.connectorTypes);
      }

      if (params.maxPrice != null) {
        query = query.where('price_per_unit', isLessThanOrEqualTo: params.maxPrice);
      }

      if (params.minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: params.minRating);
      }

      query = query.orderBy('updated_at', descending: true);

      if (params.limit != null) {
        query = query.limit(params.limit!);
      } else {
        query = query.limit(ApiConstants.defaultPageSize);
      }

      return query.snapshots().map((snapshot) {
        var stations = snapshot.docs
            .map((doc) => StationModel.fromFirestore(doc))
            .toList();

        if (params.latitude != null && params.longitude != null) {
          stations = stations.map((station) {
            final distance = AppUtils.calculateDistance(
              params.latitude!,
              params.longitude!,
              station.latitude,
              station.longitude,
            );
            return station.copyWith(distance: distance);
          }).toList();

          if (params.radius != null) {
            stations = stations
                .where((station) => station.distance! <= params.radius!)
                .toList();
          }

          if (params.sortBy == 'distance') {
            stations.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
          }
        }

        return stations;
      });
    } catch (e) {
      throw ServerException(message: 'Failed to get stations stream: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getConnectorTypes() async {
    try {
      final query = firestore.collection(ApiConstants.stationsCollection);
      final snapshot = await query.get();

      final Set<String> connectorTypes = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['connector_types'] != null) {
          final types = List<String>.from(data['connector_types']);
          connectorTypes.addAll(types);
        }
      }

      return connectorTypes.toList()..sort();
    } catch (e) {
      throw ServerException(message: 'Failed to get connector types: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getAmenities() async {
    try {
      final query = firestore.collection(ApiConstants.stationsCollection);
      final snapshot = await query.get();

      final Set<String> amenities = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['amenities'] != null) {
          final stationAmenities = List<String>.from(data['amenities']);
          amenities.addAll(stationAmenities);
        }
      }

      return amenities.toList()..sort();
    } catch (e) {
      throw ServerException(message: 'Failed to get amenities: ${e.toString()}');
    }
  }

  @override
  Future<void> reportStation({
    required String stationId,
    required String reason,
    String? description,
  }) async {
    try {
      await firestore.collection('station_reports').add({
        'station_id': stationId,
        'reason': reason,
        'description': description,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to report station: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStationAvailability({
    required String stationId,
    required int availablePoints,
  }) async {
    try {
      await firestore
          .collection(ApiConstants.stationsCollection)
          .doc(stationId)
          .update({
        'available_points': availablePoints,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to update station availability: ${e.toString()}');
    }
  }
}