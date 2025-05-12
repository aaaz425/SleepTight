class UpdateUserWeightRequest {
  final int weight; // 정수 값 (예: 75)

  UpdateUserWeightRequest({required this.weight});

  Map<String, dynamic> toJson() {
    return {'weight': weight};
  }
}
