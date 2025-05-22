class UpdateUserWeightRequest {
  final num weight;
  final String weightUnit;

  UpdateUserWeightRequest({required this.weight, required this.weightUnit});

  Map<String, dynamic> toJson() {
    return {'weight': weight, 'weight_unit': weightUnit};
  }
}
