import 'package:sleep_tight/features/user/domain/repositories/user_repository.dart';
import 'package:sleep_tight/features/user/data/datasources/user_remote_data_source.dart';
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
import 'package:sleep_tight/features/user/data/models/responses/user_sleep_goal_response.dart';
import 'package:sleep_tight/features/user/data/models/responses/user_information_response.dart';
import 'package:sleep_tight/features/user/data/models/responses/user_register_response.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserInformationResponse> getUserInfo() {
    return remoteDataSource.getUserInfo();
  }

  @override
  Future<UserSleepGoalResponse> getSleepGoal() {
    return remoteDataSource.getSleepGoal();
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  Future<UserRegisterResponse> registerUser({
    required UserRegisterRequest request,
  }) {
    return remoteDataSource.registerUser(request);
  }

  @override
  Future<void> withdraw() {
    return remoteDataSource.withdraw();
  }

  @override
  Future<UserInformationResponse> updateName(UpdateUserNameRequest request) {
    return remoteDataSource.updateName(request);
  }

  @override
  Future<UserInformationResponse> updateBirthDate(
    UpdateUserBirthDateRequest request,
  ) {
    return remoteDataSource.updateBirthDate(request);
  }

  @override
  Future<UserInformationResponse> updateGender(
    UpdateUserGenderRequest request,
  ) {
    return remoteDataSource.updateGender(request);
  }

  @override
  Future<UserInformationResponse> updateCountry(
    UpdateUserCountryRequest request,
  ) {
    return remoteDataSource.updateCountry(request);
  }

  @override
  Future<UserInformationResponse> updateHeight(
    UpdateUserHeightRequest request,
  ) {
    return remoteDataSource.updateHeight(request);
  }

  @override
  Future<UserInformationResponse> updateWeight(
    UpdateUserWeightRequest request,
  ) {
    return remoteDataSource.updateWeight(request);
  }

  @override
  Future<UserInformationResponse> updateMinSleepDuration(
    UpdateUserMinSleepDurationRequest request,
  ) {
    return remoteDataSource.updateMinSleepDuration(request);
  }

  @override
  Future<UserInformationResponse> updateSleepTime(
    UpdateUserSleepTimeRequest request,
  ) {
    return remoteDataSource.updateSleepTime(request);
  }

  @override
  Future<UserInformationResponse> updateWakeTime(
    UpdateUserWakeTimeRequest request,
  ) {
    return remoteDataSource.updateWakeTime(request);
  }
}
