class UserRegisterRequest {
  final String firstName;
  final String lastName;
  final String gender; // Male, Female
  final String birthDate; // YYYY-MM-DD
  final String country; // 국가 풀 네임
  final num height; // 1미터 이상 3미터 이하
  final num weight; // 20kg 이상 300kg 이하
  final String lengthUnit;
  final String weightUnit;

  UserRegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthDate,
    required this.country,
    required this.height,
    required this.weight,
    required this.lengthUnit,
    required this.weightUnit,
  });

  // fromJson()
  factory UserRegisterRequest.fromJson(Map<String, dynamic> json) {
    return UserRegisterRequest(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      gender: json['gender'] as String,
      birthDate: json['birth_date'] as String,
      country: json['country'] as String,
      height: json['height'] as num,
      weight: json['weight'] as num,
      lengthUnit: json['length_unit'] as String,
      weightUnit: json['weight_unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'birth_date': birthDate,
      'country': country,
      'height': height,
      'weight': weight,
      'length_unit': lengthUnit,
      'weight_unit': weightUnit,
    };
  }
}
