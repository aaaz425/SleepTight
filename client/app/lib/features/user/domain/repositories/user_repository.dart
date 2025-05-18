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

abstract class UserRepository {
  // 회원 정보 조회 (GET api/user)
  Future<UserInformationResponse> getUserInfo();

  // 수면 목표 조회 (GET api/user/sleep-goal)
  Future<UserSleepGoalResponse> getSleepGoal();

  // 로그아웃 (POST api/user/logout)
  Future<void> logout();

  // 초기 사용자 정보 입력 (POST api/user/register)
  Future<UserRegisterResponse> registerUser({
    required UserRegisterRequest request,
  });

  // 회원 탈퇴 (POST api/user/withdraw)
  Future<void> withdraw();

  // 사용자 이름 변경 (PATCH api/user/name)
  Future<UserInformationResponse> updateName(UpdateUserNameRequest request);

  // 사용자 생년월일 설정 (PATCH api/user/birth-date)
  Future<UserInformationResponse> updateBirthDate(
    UpdateUserBirthDateRequest request,
  );

  // 사용자 성별 설정 (PATCH api/user/gender)
  Future<UserInformationResponse> updateGender(UpdateUserGenderRequest request);

  // 사용자 국적 설정 (PATCH api/user/country)
  Future<UserInformationResponse> updateCountry(
    UpdateUserCountryRequest request,
  );

  // 사용자 키 설정 (PATCH api/user/height)
  Future<UserInformationResponse> updateHeight(UpdateUserHeightRequest request);

  // 사용자 몸무게 설정 (PATCH api/user/weight)
  Future<UserInformationResponse> updateWeight(UpdateUserWeightRequest request);

  // 사용자 목표 수면 시간 설정 (PATCH api/user/min-sleep-duration)
  Future<UserInformationResponse> updateMinSleepDuration(
    UpdateUserMinSleepDurationRequest request,
  );

  // 사용자 취침 시간 설정 (PATCH api/user/sleep-time) - 응답 없음
  Future<void> updateSleepTime(UpdateUserSleepTimeRequest request);

  // 사용자 기상 시간 설정 (PATCH api/user/wake-time) - 응답 없음
  Future<void> updateWakeTime(UpdateUserWakeTimeRequest request);
}
