import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/station_entity.dart';

class StationModel extends StationEntity {
  const StationModel({
    required super.id,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.availablePoints,
    required super.totalPoints,
    required super.amenities,
    required super.pricePerUnit,
    required super.connectorTypes,
    required super.rating,
    required super.reviewsCount,
    required super.isOperational,
    super.description,
    super.imageUrl,
    super.images,
    super.operatorName,
    super.operatorPhone,
    super.operatingHours,
    required super.createdAt,
    required super.updatedAt,
    super.distance,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      availablePoints: json['available_points'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      amenities: List<String>.from(json['amenities'] ?? []),
      pricePerUnit: (json['price_per_unit'] ?? 0.0).toDouble(),
      connectorTypes: List<String>.from(json['connector_types'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      isOperational: json['is_operational'] ?? true,
      description: json['description'],
      imageUrl: json['image_url'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      operatorName: json['operator_name'],
      operatorPhone: json['operator_phone'],
      operatingHours: json['operating_hours'] != null
          ? Map<String, String>.from(json['operating_hours'])
          : null,
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] is Timestamp
          ? (json['updated_at'] as Timestamp).toDate()
          : DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      distance: json['distance']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'available_points': availablePoints,
      'total_points': totalPoints,
      'amenities': amenities,
      'price_per_unit': pricePerUnit,
      'connector_types': connectorTypes,
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_operational': isOperational,
      'description': description,
      'image_url': imageUrl,
      'images': images,
      'operator_name': operatorName,
      'operator_phone': operatorPhone,
      'operating_hours': operatingHours,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      if (distance != null) 'distance': distance,
    };
  }

  factory StationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StationModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  factory StationModel.fromEntity(StationEntity entity) {
    return StationModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      availablePoints: entity.availablePoints,
      totalPoints: entity.totalPoints,
      amenities: entity.amenities,
      pricePerUnit: entity.pricePerUnit,
      connectorTypes: entity.connectorTypes,
      rating: entity.rating,
      reviewsCount: entity.reviewsCount,
      isOperational: entity.isOperational,
      description: entity.description,
      imageUrl: entity.imageUrl,
      images: entity.images,
      operatorName: entity.operatorName,
      operatorPhone: entity.operatorPhone,
      operatingHours: entity.operatingHours,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      distance: entity.distance,
    );
  }

  StationModel copyWith({
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
    return StationModel(
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
}