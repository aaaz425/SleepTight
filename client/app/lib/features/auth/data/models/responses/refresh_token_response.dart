class RefreshTokenResponseModel {
  final String accessToken;

  RefreshTokenResponseModel({required this.accessToken});

  factory RefreshTokenResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return RefreshTokenResponseModel(accessToken: data['accessToken']);
  }
}
