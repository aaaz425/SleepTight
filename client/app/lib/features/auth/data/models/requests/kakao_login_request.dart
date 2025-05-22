class KakaoLoginRequestModel {
  final String authorizationCode;
  KakaoLoginRequestModel({required this.authorizationCode});

  Map<String, dynamic> toJson() => {'AuthorizationCode': authorizationCode};
}
