class UpdateUserCountryRequest {
  final String country; // 국가 풀 네임 (예: "South Korea")

  UpdateUserCountryRequest({required this.country});

  Map<String, dynamic> toJson() {
    return {'country': country};
  }
}
