import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 6)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String fullName;

  @HiveField(1)
  final String? imagePath;

  @HiveField(2)
  final int age;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final bool isSetupComplete;

  UserProfile({
    required this.fullName,
    this.imagePath,
    required this.age,
    this.email,
    this.isSetupComplete = false,
  });

  UserProfile copyWith({
    String? fullName,
    String? imagePath,
    int? age,
    String? email,
    bool? isSetupComplete,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      imagePath: imagePath ?? this.imagePath,
      age: age ?? this.age,
      email: email ?? this.email,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'imagePath': imagePath,
      'age': age,
      'email': email,
      'isSetupComplete': isSetupComplete,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      fullName: map['fullName'],
      imagePath: map['imagePath'],
      age: map['age'],
      email: map['email'],
      isSetupComplete: map['isSetupComplete'] ?? false,
    );
  }
}
