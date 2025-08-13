import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? farmLocation;
  final double? farmSize;
  final List<String> cropTypes;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? preferences;
  final bool isVerified;
  final String? bio;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.farmLocation,
    this.farmSize,
    required this.cropTypes,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
    this.preferences,
    this.isVerified = false,
    this.bio,
  });

  // Getter for username (returns the name field)
  String get username => name;

  // Create UserProfileModel from Firestore map
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      farmLocation: map['farmLocation'],
      farmSize: map['farmSize']?.toDouble(),
      cropTypes: List<String>.from(map['cropTypes'] ?? []),
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      preferences: map['preferences'] as Map<String, dynamic>?,
      isVerified: map['isVerified'] ?? false,
      bio: map['bio'],
    );
  }

  // Create UserProfileModel from Firestore DocumentSnapshot
  factory UserProfileModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    return UserProfileModel.fromMap(data);
  }

  // Create UserProfileModel from JSON string
  factory UserProfileModel.fromJson(String jsonStr) {
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    
    // Handle DateTime parsing from ISO string
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.parse(value);
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return UserProfileModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      farmLocation: map['farmLocation'],
      farmSize: map['farmSize']?.toDouble(),
      cropTypes: List<String>.from(map['cropTypes'] ?? []),
      profileImageUrl: map['profileImageUrl'],
      createdAt: parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(map['updatedAt']),
      preferences: map['preferences'] as Map<String, dynamic>?,
      isVerified: map['isVerified'] ?? false,
      bio: map['bio'],
    );
  }

  // Convert UserProfileModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'farmLocation': farmLocation,
      'farmSize': farmSize,
      'cropTypes': cropTypes,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'preferences': preferences,
      'isVerified': isVerified,
      'bio': bio,
    };
  }

  // Convert to JSON-compatible map
  Map<String, dynamic> toJsonMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'farmLocation': farmLocation,
      'farmSize': farmSize,
      'cropTypes': cropTypes,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'preferences': preferences,
      'isVerified': isVerified,
      'bio': bio,
    };
  }

  // Create a copy with updated fields
  UserProfileModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? farmLocation,
    double? farmSize,
    List<String>? cropTypes,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    bool? isVerified,
    String? bio,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      farmLocation: farmLocation ?? this.farmLocation,
      farmSize: farmSize ?? this.farmSize,
      cropTypes: cropTypes ?? this.cropTypes,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      isVerified: isVerified ?? this.isVerified,
      bio: bio ?? this.bio,
    );
  }

  // Convert to JSON string
  String toJson() {
    return json.encode(toJsonMap());
  }

  // Check if the profile is complete
  bool get isProfileComplete {
    return uid.isNotEmpty &&
        name.isNotEmpty &&
        email.isNotEmpty &&
        farmLocation != null &&
        farmLocation!.isNotEmpty &&
        farmSize != null &&
        cropTypes.isNotEmpty;
  }

  // Get display name (fallback to email if name is empty)
  String get displayName {
    return name.isNotEmpty ? name : email.split('@').first;
  }

  @override
  String toString() {
    return 'UserProfileModel(uid: $uid, name: $name, email: $email, phone: $phone, farmLocation: $farmLocation, farmSize: $farmSize, cropTypes: $cropTypes, profileImageUrl: $profileImageUrl, createdAt: $createdAt, updatedAt: $updatedAt, preferences: $preferences, isVerified: $isVerified, bio: $bio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    bool listEquals<T>(List<T>? a, List<T>? b) {
      if (a == null) return b == null;
      if (b == null || a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    bool mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
      if (a == null) return b == null;
      if (b == null || a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || a[key] != b[key]) return false;
      }
      return true;
    }

    return other is UserProfileModel &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.farmLocation == farmLocation &&
        other.farmSize == farmSize &&
        listEquals(other.cropTypes, cropTypes) &&
        other.profileImageUrl == profileImageUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        mapEquals(other.preferences, preferences) &&
        other.isVerified == isVerified &&
        other.bio == bio;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        (phone?.hashCode ?? 0) ^
        (farmLocation?.hashCode ?? 0) ^
        (farmSize?.hashCode ?? 0) ^
        Object.hashAll(cropTypes) ^
        (profileImageUrl?.hashCode ?? 0) ^
        createdAt.hashCode ^
        (updatedAt?.hashCode ?? 0) ^
        (preferences?.hashCode ?? 0) ^
        isVerified.hashCode ^
        (bio?.hashCode ?? 0);
  }

  get farmingExperience => null;
}