import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/user/data/models/requests/user_register_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_name_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_birth_date_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_gender_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_country_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_height_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_weight_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_min_sleep_duration_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_sleep_time_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_wake_time_request.dart';
import 'package:sleep_tight/features/user/data/models/responses/user_information_response.dart';
import 'package:sleep_tight/features/user/data/models/responses/user_register_response.dart';
import 'package:sleep_tight/features/user/data/models/responses/user_sleep_goal_response.dart';
import 'package:sleep_tight/core/config/app_config.dart';

abstract class UserRemoteDataSource {
  Future<UserInformationResponse> getUserInfo();
  Future<UserSleepGoalResponse> getSleepGoal();
  Future<void> logout();
  Future<UserRegisterResponse> registerUser(UserRegisterRequest request);
  Future<UserInformationResponse> withdraw();

  Future<UserInformationResponse> updateName(UpdateUserNameRequest request);
  Future<UserInformationResponse> updateBirthDate(
    UpdateUserBirthDateRequest request,
  );
  Future<UserInformationResponse> updateGender(UpdateUserGenderRequest request);
  Future<UserInformationResponse> updateCountry(
    UpdateUserCountryRequest request,
  );
  Future<UserInformationResponse> updateHeight(UpdateUserHeightRequest request);
  Future<UserInformationResponse> updateWeight(UpdateUserWeightRequest request);
  Future<UserInformationResponse> updateMinSleepDuration(
    UpdateUserMinSleepDurationRequest request,
  );

  Future<void> updateSleepTime(UpdateUserSleepTimeRequest request);
  Future<void> updateWakeTime(UpdateUserWakeTimeRequest request);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;
  final ApiPaths apiPaths;

  UserRemoteDataSourceImpl(this.dio, this.apiPaths);

  @override
  Future<UserInformationResponse> getUserInfo() async {
    final response = await dio.get(apiPaths.user.base);
    return UserInformationResponse.fromJson(response.data);
  }

  @override
  Future<UserSleepGoalResponse> getSleepGoal() async {
    final response = await dio.get(apiPaths.user.sleepGoal);
    return UserSleepGoalResponse.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    await dio.post(apiPaths.user.logout);
    // TODO: cleartoken
  }

  @override
  Future<UserRegisterResponse> registerUser(UserRegisterRequest request) async {
    final response = await dio.post(
      apiPaths.user.register,
      data: request.toJson(),
    );
    return UserRegisterResponse.fromJson(response.data);
  }

  @override
  Future<UserInformationResponse> withdraw() async {
    final response = await dio.post(apiPaths.user.withdraw);
    return UserInformationResponse.fromJson(response.data);
  }

  @override
  Future<UserInformationResponse> updateName(
    UpdateUserNameRequest request,
  ) async {
    final response = await dio.patch(
      apiPaths.user.name,
      data: request.toJson(),
    );
    return UserInformationResponse.fromJson(response.data);
  }

  @override
  Future<UserInformationResponse> updateBirthDate(
    UpdateUserBirthDateRequest request,
  ) async {
    final response = await dio.patch(
      apiPaths.user.birthDate,
      data: request.toJson(),
    );
    return UserInformationResponse.fromJson(response.data);
  }

  @override
  Future<UserInformationResponse> updateGender(
    UpdateUserGenderRequest request,
  ) async {
    final response = await dio.patch(
      apiPaths.user.gender,
      data: request.toJson(),
    );
    return UserInformationResponse.fromJson(response.data);
  }

  @override
  Future<UserInformationResponse> updateCountry(
    UpdateUserCountryRequest request,
  ) async {
    final response = await dio.patch(
      apiPaths.user.country,
      data: request.toJson(),
    );
    return UserInformationResponse.fromJson(response.data);
  }

  @override
  Future<UserInformationResponse> updateHeight(
    UpdateUserHeightRequest request,
  ) async {
    final response = await dio.patch(
      apiPaths.user.height,
      data: request.toJson(),
    );
    return UserInformationResponse.fromJson(response.data);
  }

  @override
  Future<UserInformationResponse> updateWeight(
    UpdateUserWeightRequest request,
  ) async {
    final response = await dio.patch(
      apiPaths.user.weight,
      data: request.toJson(),
    );
    return UserInformationResponse.fromJson(response.data);
  }

  @override
  Future<UserInformationResponse> updateMinSleepDuration(
    UpdateUserMinSleepDurationRequest request,
  ) async {
    final response = await dio.patch(
      apiPaths.user.minSleepDuration,
      data: request.toJson(),
    );
    return UserInformationResponse.fromJson(response.data);
  }

  @override
  Future<void> updateSleepTime(UpdateUserSleepTimeRequest request) async {
    await dio.patch(apiPaths.user.sleepTime, data: request.toJson());
  }

  @override
  Future<void> updateWakeTime(UpdateUserWakeTimeRequest request) async {
    await dio.patch(apiPaths.user.wakeTime, data: request.toJson());
  }
}

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider); // DioClient 인스턴스
  final apiPaths = ApiPaths(); // API 경로 관리 객체
  return UserRemoteDataSourceImpl(dioClient.dio, apiPaths);
});
