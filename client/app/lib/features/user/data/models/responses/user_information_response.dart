class UserInformationResponse {
  final int id;
  final String provider;
  final String lastName;
  final String firstName;
  final String email;
  final String wakeTime; // "HH:MM:SS"
  final String sleepTime; // "HH:MM:SS"
  final MinSleepDuration minSleepDuration;
  final int weight;
  final int height;
  final String gender;
  final String birthDate; // "YYYY-MM-DD"
  final String country;
  final String lengthUnit;
  final String weightUnit;
  final String status;

  UserInformationResponse({
    required this.id,
    required this.provider,
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.wakeTime,
    required this.sleepTime,
    required this.minSleepDuration,
    required this.weight,
    required this.height,
    required this.gender,
    required this.birthDate,
    required this.country,
    required this.lengthUnit,
    required this.weightUnit,
    required this.status,
  });

  factory UserInformationResponse.fromJson(Map<String, dynamic> json) {
    return UserInformationResponse(
      id: json['id'],
      provider: json['provider'],
      lastName: json['lastName'],
      firstName: json['firstName'],
      email: json['email'],
      wakeTime: json['wakeTime'],
      sleepTime: json['sleepTime'],
      minSleepDuration: MinSleepDuration.fromJson(json['minSleepDuration']),
      weight: json['weight'],
      height: json['height'],
      gender: json['gender'],
      birthDate: json['birthDate'],
      country: json['country'],
      lengthUnit: json['lengthUnit'],
      weightUnit: json['weightUnit'],
      status: json['status'],
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'lastName': lastName,
      'firstName': firstName,
      'email': email,
      'wakeTime': wakeTime,
      'sleepTime': sleepTime,
      'minSleepDuration': minSleepDuration.toJson(),
      'weight': weight,
      'height': height,
      'gender': gender,
      'birthDate': birthDate,
      'country': country,
      'lengthUnit': lengthUnit,
      'weightUnit': weightUnit,
      'status': status,
    };
  }
}

class MinSleepDuration {
  final int hours;
  final int minutes;
  final int seconds;

  MinSleepDuration({
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  factory MinSleepDuration.fromJson(Map<String, dynamic> json) {
    return MinSleepDuration(
      hours: json['hours'] ?? 0,
      minutes: json['minutes'] ?? 0,
      seconds: json['seconds'] ?? 0,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {'hours': hours, 'minutes': minutes, 'seconds': seconds};
  }
}
