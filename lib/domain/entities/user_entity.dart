import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool isActive;
  final List<String> favoriteStations;
  final Map<String, dynamic>? preferences;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isEmailVerified,
    required this.isActive,
    required this.favoriteStations,
    this.preferences,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isActive,
    List<String>? favoriteStations,
    Map<String, dynamic>? preferences,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      favoriteStations: favoriteStations ?? this.favoriteStations,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phoneNumber,
        profileImageUrl,
        createdAt,
        updatedAt,
        isEmailVerified,
        isActive,
        favoriteStations,
        preferences,
      ];

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, fullName: $fullName, isEmailVerified: $isEmailVerified, isActive: $isActive)';
  }
}