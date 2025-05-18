class KakaoLoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final String status;

  KakaoLoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.status,
  });

  factory KakaoLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return KakaoLoginResponseModel(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      status: json['status'],
    );
  }
}
