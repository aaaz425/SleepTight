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
    final data = json['data'];
    return KakaoLoginResponseModel(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
      status: data['status'],
    );
  }
}
