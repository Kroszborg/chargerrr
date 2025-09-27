class ApiConstants {
  static const String baseUrl = 'https://api.chargerrr.com';

  static const String stationsCollection = 'charging_stations';
  static const String usersCollection = 'users';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const int defaultPageSize = 20;
  static const double defaultSearchRadius = 50.0; // in kilometers

  static const Map<String, String> amenityIcons = {
    'wifi': '📶',
    'restroom': '🚻',
    'cafe': '☕',
    'food_court': '🍽️',
    'parking': '🅿️',
    'shopping': '🛍️',
    'atm': '🏧',
    'gas_station': '⛽',
  };

  static const Map<String, String> connectorTypeIcons = {
    'Type 1': '🔌',
    'Type 2': '⚡',
    'CCS': '🔋',
    'CHAdeMO': '⚡',
    'Tesla': '🏎️',
  };

  static const List<String> filterCategories = [
    'distance',
    'price',
    'availability',
    'rating',
    'connector_type',
  ];

  static const Map<String, double> priceRanges = {
    'budget': 5.0,
    'standard': 10.0,
    'premium': 15.0,
  };

  static const Map<String, double> distanceRanges = {
    'nearby': 5.0,
    'moderate': 15.0,
    'far': 50.0,
  };
}