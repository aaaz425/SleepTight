import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/features/auth/data/models/requests/kakao_login_request.dart';
import 'package:sleep_tight/features/auth/data/models/responses/kakao_login_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

abstract class AuthRemoteDataSource {
  Future<KakaoLoginResponseModel> loginWithKakao(
    KakaoLoginRequestModel request,
  );
  Future<String> refreshAccessToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<KakaoLoginResponseModel> loginWithKakao(
    KakaoLoginRequestModel request,
  ) async {
    final response = await dio.post(
      AppConfig.api.auth.kakao,
      data: request.toJson(),
    );
    debugPrint('카카오 로그인 요청 후: $response');
    return KakaoLoginResponseModel.fromJson(response.data);
  }

  @override
  Future<String> refreshAccessToken(String refreshToken) async {
    final response = await dio.post(
      AppConfig.api.auth.refresh,
      data: {'refreshToken': refreshToken},
    );
    return response.data['data']['accessToken'];
  }
}
