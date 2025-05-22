class UpdateUserHeightRequest {
  final num height; // 소수 둘째자리 까지
  final String lengthUnit;

  UpdateUserHeightRequest({required this.height, required this.lengthUnit});

  Map<String, dynamic> toJson() {
    return {'height': height, 'length_unit': lengthUnit};
  }
}
