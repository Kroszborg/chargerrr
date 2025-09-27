import 'package:equatable/equatable.dart';

class StationEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int availablePoints;
  final int totalPoints;
  final List<String> amenities;
  final double pricePerUnit;
  final List<String> connectorTypes;
  final double rating;
  final int reviewsCount;
  final bool isOperational;
  final String? description;
  final String? imageUrl;
  final List<String>? images;
  final String? operatorName;
  final String? operatorPhone;
  final Map<String, String>? operatingHours;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distance;

  const StationEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.availablePoints,
    required this.totalPoints,
    required this.amenities,
    required this.pricePerUnit,
    required this.connectorTypes,
    required this.rating,
    required this.reviewsCount,
    required this.isOperational,
    this.description,
    this.imageUrl,
    this.images,
    this.operatorName,
    this.operatorPhone,
    this.operatingHours,
    required this.createdAt,
    required this.updatedAt,
    this.distance,
  });

  StationEntity copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? availablePoints,
    int? totalPoints,
    List<String>? amenities,
    double? pricePerUnit,
    List<String>? connectorTypes,
    double? rating,
    int? reviewsCount,
    bool? isOperational,
    String? description,
    String? imageUrl,
    List<String>? images,
    String? operatorName,
    String? operatorPhone,
    Map<String, String>? operatingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
  }) {
    return StationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availablePoints: availablePoints ?? this.availablePoints,
      totalPoints: totalPoints ?? this.totalPoints,
      amenities: amenities ?? this.amenities,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      connectorTypes: connectorTypes ?? this.connectorTypes,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isOperational: isOperational ?? this.isOperational,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      operatorName: operatorName ?? this.operatorName,
      operatorPhone: operatorPhone ?? this.operatorPhone,
      operatingHours: operatingHours ?? this.operatingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
    );
  }

  bool get hasAvailablePoints => availablePoints > 0;

  bool get isFullyBooked => availablePoints == 0;

  double get occupancyPercentage =>
      totalPoints > 0 ? ((totalPoints - availablePoints) / totalPoints) * 100 : 0;

  String get availabilityStatus {
    if (!isOperational) return 'Under Maintenance';
    if (availablePoints == 0) return 'Fully Occupied';
    if (availablePoints <= totalPoints * 0.2) return 'Almost Full';
    return 'Available';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
        availablePoints,
        totalPoints,
        amenities,
        pricePerUnit,
        connectorTypes,
        rating,
        reviewsCount,
        isOperational,
        description,
        imageUrl,
        images,
        operatorName,
        operatorPhone,
        operatingHours,
        createdAt,
        updatedAt,
        distance,
      ];

  @override
  String toString() {
    return 'StationEntity(id: $id, name: $name, address: $address, availablePoints: $availablePoints/$totalPoints, rating: $rating, isOperational: $isOperational)';
  }
}