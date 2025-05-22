import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/features/auth/data/models/requests/kakao_login_request.dart';
import 'package:sleep_tight/features/auth/data/models/requests/refresh_token_request.dart';
import 'package:sleep_tight/features/auth/data/models/responses/kakao_login_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:sleep_tight/features/auth/data/models/responses/refresh_token_response.dart';

abstract class AuthRemoteDataSource {
  Future<KakaoLoginResponseModel> loginWithKakao(
    KakaoLoginRequestModel request,
  );
  Future<RefreshTokenResponseModel> refreshAccessToken(
    RefreshTokenRequestModel request,
  );
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
  Future<RefreshTokenResponseModel> refreshAccessToken(
    RefreshTokenRequestModel request,
  ) async {
    final response = await dio.post(
      AppConfig.api.auth.refresh,
      data: request.toJson(),
    );
    return RefreshTokenResponseModel.fromJson(response.data);
  }
}
