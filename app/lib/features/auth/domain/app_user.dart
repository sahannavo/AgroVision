import 'package:flutter/foundation.dart';

/// Represents an authenticated user in the AgroVision application.
@immutable
class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final double? latitude;
  final double? longitude;
  final String region;
  final String soilType;
  final double landSize;

  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    this.latitude,
    this.longitude,
    required this.region,
    required this.soilType,
    required this.landSize,
  });

  AppUser copyWith({
    String? uid,
    String? email,
    String? fullName,
    double? latitude,
    double? longitude,
    String? region,
    String? soilType,
    double? landSize,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      region: region ?? this.region,
      soilType: soilType ?? this.soilType,
      landSize: landSize ?? this.landSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          fullName == other.fullName &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          region == other.region &&
          soilType == other.soilType &&
          landSize == other.landSize;

  @override
  int get hashCode => Object.hash(
        uid,
        email,
        fullName,
        latitude,
        longitude,
        region,
        soilType,
        landSize,
      );

  @override
  String toString() =>
      'AppUser(uid: $uid, email: $email, fullName: $fullName, region: $region, soilType: $soilType, landSize: $landSize)';
}

