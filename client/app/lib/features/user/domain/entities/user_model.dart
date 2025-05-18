import 'package:sleep_tight/features/user/data/models/enums/auth_status.dart';

class UserModel {
  final int? id;
  final String? provider;
  final String? lastName;
  final String? firstName;
  final String? email;
  final String? wakeTime; // HH:MM:SS 형식
  final String? sleepTime; // HH:MM:SS 형식
  final int? minSleepDurationInMinutes; // 총 분 단위 목표 수면 시간
  final num? weight; // API 응답이 정수 또는 실수일 수 있으므로 num 사용
  final num? height; // API 응답이 정수 또는 실수일 수 있으므로 num 사용
  final String? gender; // "male", "female"
  final String? birthDate; // YYYY-MM-DD 형식
  final String? country;
  final String? lengthUnit; // "cm", "inch"
  final String? weightUnit; // "kg", "lb"
  final AuthStatus? status;

  String? get fullName {
    if (firstName != null && lastName != null) {
      return '$lastName$firstName';
    }
    if (firstName != null) return firstName;
    if (lastName != null) return lastName;
    return null;
  }

  UserModel({
    this.id,
    this.provider,
    this.lastName,
    this.firstName,
    this.email,
    this.wakeTime,
    this.sleepTime,
    this.minSleepDurationInMinutes,
    this.weight,
    this.height,
    this.gender,
    this.birthDate,
    this.country,
    this.lengthUnit,
    this.weightUnit,
    this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json;

    int? calculatedMinSleepDurationInMinutes;
    if (data['minSleepDuration'] != null && data['minSleepDuration'] is Map) {
      final durationMap = data['minSleepDuration'] as Map<String, dynamic>;
      final hours = (durationMap['hours'] as num?)?.toInt();
      final minutes = (durationMap['minutes'] as num?)?.toInt();

      if (hours != null || minutes != null) {
        calculatedMinSleepDurationInMinutes =
            (hours ?? 0) * 60 + (minutes ?? 0);
      }
    }

    return UserModel(
      id: data['id'] as int?,
      provider: data['provider'] as String?,
      lastName: data['lastName'] as String?,
      firstName: data['firstName'] as String?,
      email: data['email'] as String?,
      wakeTime: data['wakeTime'] as String?,
      sleepTime: data['sleepTime'] as String?,
      minSleepDurationInMinutes: calculatedMinSleepDurationInMinutes,
      weight: data['weight'] as num?,
      height: data['height'] as num?,
      gender: data['gender'] as String?,
      birthDate: data['birthDate'] as String?,
      country: data['country'] as String?,
      lengthUnit: data['lengthUnit'] as String?,
      weightUnit: data['weightUnit'] as String?,
      status: AuthStatus.fromString(data['status'] as String?),
    );
  }
}