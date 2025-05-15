import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/features/user/data/models/enums/auth_status.dart';
import 'package:sleep_tight/features/user/data/models/responses/user_information_response.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_birth_date_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_country_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_gender_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_height_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_min_sleep_duration_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_name_request.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_weight_request.dart';
import 'package:sleep_tight/features/user/domain/entities/user_model.dart';
import 'package:sleep_tight/features/user/domain/repositories/user_repository.dart';
import 'package:sleep_tight/features/user/data/repositories/user_repository_impl.dart';
import 'package:sleep_tight/features/user/data/datasources/user_remote_data_source.dart';

// UserRepository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource);
});

// UserModel StateNotifierProvider
final userModelProvider = StateNotifierProvider<UserModelNotifier, UserModel?>((
  ref,
) {
  final repo = ref.watch(userRepositoryProvider);
  return UserModelNotifier(repo);
});

class UserModelNotifier extends StateNotifier<UserModel?> {
  final UserRepository repo;
  UserModelNotifier(this.repo) : super(null) {
    // loadUser();
  }

  // PATCH/PUT 등에서 받은 UserInformationResponse를 바로 state로 반영
  void updateFromResponse(UserInformationResponse response) {
    state = UserModel.fromJson(response.toJson());
  }

  // 최초 유저 정보 불러오기 (GET)
  Future<void> loadUser() async {
    final userInfoResponse = await repo.getUserInfo();
    updateFromResponse(userInfoResponse);
  }

  // 이름 변경
  Future<void> updateName(UpdateUserNameRequest request) async {
    final response = await repo.updateName(request);
    updateFromResponse(response);
  }

  // 생년월일 변경
  Future<void> updateBirthDate(UpdateUserBirthDateRequest request) async {
    final response = await repo.updateBirthDate(request);
    updateFromResponse(response);
  }

  // 성별 변경
  Future<void> updateGender(UpdateUserGenderRequest request) async {
    final response = await repo.updateGender(request);
    updateFromResponse(response);
  }

  // 국가 변경
  Future<void> updateCountry(UpdateUserCountryRequest request) async {
    final response = await repo.updateCountry(request);
    updateFromResponse(response);
  }

  // 키 변경
  Future<void> updateHeight(UpdateUserHeightRequest request) async {
    final response = await repo.updateHeight(request);
    updateFromResponse(response);
  }

  // 몸무게 변경
  Future<void> updateWeight(UpdateUserWeightRequest request) async {
    final response = await repo.updateWeight(request);
    updateFromResponse(response);
  }

  // 최소 수면 시간 변경
  Future<void> updateMinSleepDuration(
    UpdateUserMinSleepDurationRequest request,
  ) async {
    final response = await repo.updateMinSleepDuration(request);
    updateFromResponse(response);
  }

  // getStatus
  AuthStatus getStatus() {
    if (state == null) {
      return AuthStatus.guest;
    }
    return state!.status!;
  }

  // setStatus
  void setStatus(AuthStatus status) {
    state = UserModel(status: status);
  }

  void clear() => state = null;
}
