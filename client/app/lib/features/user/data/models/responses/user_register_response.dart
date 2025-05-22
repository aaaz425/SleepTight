import 'package:sleep_tight/features/user/data/models/responses/user_information_response.dart';

class UserRegisterResponse {
  final String accessToken;
  final String refreshToken;
  final UserInformationResponse userInfo;

  UserRegisterResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userInfo,
  });

  factory UserRegisterResponse.fromJson(Map<String, dynamic> json) {
    return UserRegisterResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      userInfo: UserInformationResponse.fromJson(json),
    );
  }
}
