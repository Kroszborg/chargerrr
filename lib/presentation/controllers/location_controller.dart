import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/usecases/get_user_location.dart';
import '../../domain/entities/station_entity.dart';
import '../../core/constants/app_colors.dart';

class LocationController extends GetxController {
  final GetUserLocation getUserLocation;

  LocationController({required this.getUserLocation});

  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  final RxBool isLoading = false.obs;
  final RxBool locationPermissionGranted = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<CameraPosition> initialCameraPosition = const CameraPosition(
    target: LatLng(28.6139, 77.2090), // Delhi, India
    zoom: 12.0,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await getUserLocation.getCurrentLocation();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        locationPermissionGranted.value = false;
        _showError(failure.message);
      },
      (locationData) {
        currentLocation.value = LatLng(
          locationData.latitude,
          locationData.longitude,
        );
        locationPermissionGranted.value = true;

        _updateCameraPosition(
          LatLng(locationData.latitude, locationData.longitude),
        );

        _addCurrentLocationMarker();
      },
    );

    isLoading.value = false;
  }

  Future<void> checkLocationPermission() async {
    final result = await getUserLocation.checkLocationPermission();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        locationPermissionGranted.value = false;
      },
      (permission) {
        locationPermissionGranted.value = permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
      },
    );
  }

  Future<void> requestLocationPermission() async {
    final result = await getUserLocation.requestLocationPermission();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        locationPermissionGranted.value = false;
        _showError(failure.message);
      },
      (permission) {
        locationPermissionGranted.value = permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;

        if (locationPermissionGranted.value) {
          getCurrentLocation();
        }
      },
    );
  }

  Future<void> openLocationSettings() async {
    final result = await getUserLocation.openLocationSettings();
    result.fold(
      (failure) => _showError(failure.message),
      (_) {
        // Settings opened successfully
      },
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentLocation.value != null) {
      _addCurrentLocationMarker();
    }
  }

  Future<void> addStationMarkers(List<StationEntity> stations) async {
    markers.clear();

    if (currentLocation.value != null) {
      _addCurrentLocationMarker();
    }

    for (final station in stations) {
      markers.add(
        Marker(
          markerId: MarkerId(station.id),
          position: LatLng(station.latitude, station.longitude),
          infoWindow: InfoWindow(
            title: station.name,
            snippet: '${station.availablePoints}/${station.totalPoints} available',
          ),
          icon: await _getStationMarkerIcon(station),
          onTap: () => _onStationMarkerTapped(station),
        ),
      );
    }
  }

  Future<void> animateToLocation(LatLng location, {double zoom = 15.0}) async {
    if (mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: zoom),
        ),
      );
    }
  }

  Future<void> animateToStation(StationEntity station) async {
    final location = LatLng(station.latitude, station.longitude);
    await animateToLocation(location);
  }

  Future<void> animateToCurrentLocation() async {
    if (currentLocation.value != null) {
      await animateToLocation(currentLocation.value!);
    }
  }

  void _updateCameraPosition(LatLng location) {
    initialCameraPosition.value = CameraPosition(
      target: location,
      zoom: 15.0,
    );
  }

  void _addCurrentLocationMarker() {
    if (currentLocation.value == null) return;

    markers.removeWhere((marker) => marker.markerId.value == 'current_location');

    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: currentLocation.value!,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  Future<BitmapDescriptor> _getStationMarkerIcon(StationEntity station) async {
    if (!station.isOperational) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else if (station.hasAvailablePoints) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  void _onStationMarkerTapped(StationEntity station) {
    Get.find<dynamic>().selectStation(station);
    Get.toNamed('/station-details', arguments: station);
  }

  void clearMarkers() {
    markers.clear();
  }

  void _showError(String message) {
    Get.snackbar(
      'Location Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          if (message.contains('permission')) {
            requestLocationPermission();
          } else if (message.contains('disabled')) {
            openLocationSettings();
          }
        },
        child: Text(
          message.contains('permission') ? 'Grant Permission' : 'Open Settings',
          style: TextStyle(color: Get.theme.colorScheme.onError),
        ),
      ),
    );
  }

  void clearError() {
    errorMessage.value = '';
  }

  bool get hasError => errorMessage.value.isNotEmpty;
  bool get hasCurrentLocation => currentLocation.value != null;
  bool get isLocationAvailable => locationPermissionGranted.value && hasCurrentLocation;

  LatLng? get userLocation => currentLocation.value;
  double? get userLatitude => currentLocation.value?.latitude;
  double? get userLongitude => currentLocation.value?.longitude;
}