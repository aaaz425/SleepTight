class UpdateUserGenderRequest {
  final String gender; // API 요청 시 "Male" 또는 "Female" 값 사용

  UpdateUserGenderRequest({required this.gender});

  Map<String, dynamic> toJson() {
    return {'gender': gender};
  }
}
