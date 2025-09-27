import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/errors/failures.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
  }
}

class GetUserLocation {
  Future<Either<Failure, LocationData>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(
          LocationFailure(message: 'Location services are disabled'),
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(
            LocationFailure(message: 'Location permission denied'),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const Left(
          LocationFailure(
            message: 'Location permissions are permanently denied',
          ),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return Right(
        LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp ?? DateTime.now(),
        ),
      );
    } catch (e) {
      return Left(
        LocationFailure(message: 'Failed to get location: ${e.toString()}'),
      );
    }
  }

  Stream<Either<Failure, LocationData>> getLocationStream() async* {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        yield const Left(
          LocationFailure(message: 'Location services are disabled'),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          yield const Left(
            LocationFailure(message: 'Location permission denied'),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        yield const Left(
          LocationFailure(
            message: 'Location permissions are permanently denied',
          ),
        );
        return;
      }

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      await for (final position in Geolocator.getPositionStream(
        locationSettings: locationSettings,
      )) {
        yield Right(
          LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            timestamp: position.timestamp ?? DateTime.now(),
          ),
        );
      }
    } catch (e) {
      yield Left(
        LocationFailure(message: 'Failed to get location stream: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, bool>> isLocationServiceEnabled() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      return Right(isEnabled);
    } catch (e) {
      return Left(
        LocationFailure(message: 'Failed to check location service: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, LocationPermission>> checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return Right(permission);
    } catch (e) {
      return Left(
        LocationFailure(message: 'Failed to check location permission: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, LocationPermission>> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return Right(permission);
    } catch (e) {
      return Left(
        LocationFailure(message: 'Failed to request location permission: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, void>> openLocationSettings() async {
    try {
      final opened = await Geolocator.openLocationSettings();
      if (opened) {
        return const Right(null);
      } else {
        return const Left(
          LocationFailure(message: 'Failed to open location settings'),
        );
      }
    } catch (e) {
      return Left(
        LocationFailure(message: 'Failed to open location settings: ${e.toString()}'),
      );
    }
  }
}