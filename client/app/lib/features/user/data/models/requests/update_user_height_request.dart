class UpdateUserHeightRequest {
  final int height; // 정수 값 (예: 180)

  UpdateUserHeightRequest({required this.height});

  Map<String, dynamic> toJson() {
    return {'height': height};
  }
}
