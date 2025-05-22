class UpdateUserBirthDateRequest {
  final String birthDate; // "YYYY-MM-DD" 형식

  UpdateUserBirthDateRequest({required this.birthDate});

  Map<String, dynamic> toJson() {
    return {'birthDate': birthDate};
  }
}
