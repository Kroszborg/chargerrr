import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/station_entity.dart';
import '../../domain/repositories/station_repository.dart';
import '../../domain/usecases/get_stations.dart';

class StationController extends GetxController {
  final GetStations getStations;

  StationController({required this.getStations});

  final RxList<StationEntity> stations = <StationEntity>[].obs;
  final RxList<StationEntity> filteredStations = <StationEntity>[].obs;
  final RxList<StationEntity> favoriteStations = <StationEntity>[].obs;
  final RxList<String> connectorTypes = <String>[].obs;
  final RxList<String> amenities = <String>[].obs;

  final Rx<StationEntity?> selectedStation = Rx<StationEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  final Rx<double?> userLatitude = Rx<double?>(null);
  final Rx<double?> userLongitude = Rx<double?>(null);

  final RxList<String> selectedConnectorTypes = <String>[].obs;
  final RxList<String> selectedAmenities = <String>[].obs;
  final RxDouble maxPrice = 20.0.obs;
  final RxDouble minRating = 0.0.obs;
  final RxBool availableOnly = false.obs;
  final RxString sortBy = 'distance'.obs;

  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMoreData = true;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      loadConnectorTypes(),
      loadAmenities(),
    ]);
  }

  Future<void> loadStations({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMoreData = true;
      stations.clear();
      filteredStations.clear();
    }

    if (!_hasMoreData) return;

    if (_currentPage == 0) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    errorMessage.value = '';

    final params = GetStationsParams(
      latitude: userLatitude.value,
      longitude: userLongitude.value,
      radius: ApiConstants.defaultSearchRadius,
      searchQuery: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      connectorTypes: selectedConnectorTypes.isNotEmpty ? selectedConnectorTypes : null,
      maxPrice: maxPrice.value < 20.0 ? maxPrice.value : null,
      minRating: minRating.value > 0.0 ? minRating.value : null,
      availableOnly: availableOnly.value,
      sortBy: sortBy.value,
      limit: _pageSize,
      offset: _currentPage * _pageSize,
    );

    final result = await getStations.call(params);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        _showError(failure.message);
      },
      (newStations) {
        if (newStations.length < _pageSize) {
          _hasMoreData = false;
        }

        if (_currentPage == 0) {
          stations.value = newStations;
        } else {
          stations.addAll(newStations);
        }

        _applyFilters();
        _currentPage++;
      },
    );

    isLoading.value = false;
    isLoadingMore.value = false;
  }

  Future<void> searchStations(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      await loadStations(refresh: true);
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await getStations.search(
      query: query,
      latitude: userLatitude.value,
      longitude: userLongitude.value,
      limit: 50,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        _showError(failure.message);
      },
      (searchResults) {
        stations.value = searchResults;
        _applyFilters();
      },
    );

    isLoading.value = false;
  }

  Future<void> loadNearbyStations() async {
    if (userLatitude.value == null || userLongitude.value == null) {
      errorMessage.value = 'Location not available';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await getStations.getNearby(
      latitude: userLatitude.value!,
      longitude: userLongitude.value!,
      radius: 10.0,
      limit: 30,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        _showError(failure.message);
      },
      (nearbyStations) {
        stations.value = nearbyStations;
        _applyFilters();
      },
    );

    isLoading.value = false;
  }

  Future<void> loadStationDetails(String stationId) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await getStations.getById(stationId);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        _showError(failure.message);
      },
      (station) {
        selectedStation.value = station;
      },
    );

    isLoading.value = false;
  }

  Future<void> loadFavoriteStations() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await getStations.getFavorites([]);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        _showError(failure.message);
      },
      (favorites) {
        favoriteStations.value = favorites;
      },
    );

    isLoading.value = false;
  }

  Future<void> loadConnectorTypes() async {
    final result = await getStations.getConnectorTypes();
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (types) => connectorTypes.value = types,
    );
  }

  Future<void> loadAmenities() async {
    final result = await getStations.getAmenities();
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (amenitiesList) => amenities.value = amenitiesList,
    );
  }

  void setUserLocation(double latitude, double longitude) {
    userLatitude.value = latitude;
    userLongitude.value = longitude;
    loadStations(refresh: true);
  }

  void selectStation(StationEntity station) {
    selectedStation.value = station;
  }

  void clearSelectedStation() {
    selectedStation.value = null;
  }

  void addConnectorTypeFilter(String type) {
    if (!selectedConnectorTypes.contains(type)) {
      selectedConnectorTypes.add(type);
      _applyFilters();
    }
  }

  void removeConnectorTypeFilter(String type) {
    selectedConnectorTypes.remove(type);
    _applyFilters();
  }

  void addAmenityFilter(String amenity) {
    if (!selectedAmenities.contains(amenity)) {
      selectedAmenities.add(amenity);
      _applyFilters();
    }
  }

  void removeAmenityFilter(String amenity) {
    selectedAmenities.remove(amenity);
    _applyFilters();
  }

  void setPriceFilter(double price) {
    maxPrice.value = price;
    _applyFilters();
  }

  void setRatingFilter(double rating) {
    minRating.value = rating;
    _applyFilters();
  }

  void setAvailabilityFilter(bool available) {
    availableOnly.value = available;
    loadStations(refresh: true);
  }

  void setSortBy(String sort) {
    sortBy.value = sort;
    loadStations(refresh: true);
  }

  void clearFilters() {
    selectedConnectorTypes.clear();
    selectedAmenities.clear();
    maxPrice.value = 20.0;
    minRating.value = 0.0;
    availableOnly.value = false;
    searchQuery.value = '';
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<StationEntity>.from(stations);

    if (selectedConnectorTypes.isNotEmpty) {
      filtered = filtered.where((station) {
        return station.connectorTypes.any(
          (type) => selectedConnectorTypes.contains(type),
        );
      }).toList();
    }

    if (selectedAmenities.isNotEmpty) {
      filtered = filtered.where((station) {
        return station.amenities.any(
          (amenity) => selectedAmenities.contains(amenity),
        );
      }).toList();
    }

    if (maxPrice.value < 20.0) {
      filtered = filtered.where(
        (station) => station.pricePerUnit <= maxPrice.value,
      ).toList();
    }

    if (minRating.value > 0.0) {
      filtered = filtered.where(
        (station) => station.rating >= minRating.value,
      ).toList();
    }

    if (availableOnly.value) {
      filtered = filtered.where(
        (station) => station.hasAvailablePoints && station.isOperational,
      ).toList();
    }

    filteredStations.value = filtered;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  void clearError() {
    errorMessage.value = '';
  }

  bool get hasError => errorMessage.value.isNotEmpty;
  bool get hasStations => filteredStations.isNotEmpty;
  bool get hasFilters =>
      selectedConnectorTypes.isNotEmpty ||
      selectedAmenities.isNotEmpty ||
      maxPrice.value < 20.0 ||
      minRating.value > 0.0 ||
      availableOnly.value ||
      searchQuery.value.isNotEmpty;

  List<StationEntity> get stationsList => filteredStations;
  int get stationsCount => filteredStations.length;
}