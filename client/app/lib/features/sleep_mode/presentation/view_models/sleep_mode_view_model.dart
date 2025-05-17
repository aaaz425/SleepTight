import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_end_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_sound_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_start_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_end_response.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_sound_response.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_start_response.dart';
import 'package:sleep_tight/features/sleep_mode/domain/repositories/sleep_mode_repository_impl.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/report_id_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SleepModeViewModel extends StateNotifier<SleepModeState> {
  final SleepModeRepository _repository;
  final Ref _ref;

  SleepModeViewModel(this._repository, this._ref)
    : super(SleepModeState.initial());

  Future<bool> startSleep(SleepStartRequest request) async {
    state = state.copyWith(startSleep: const AsyncValue.loading());
    try {
      final response = await _repository.postSleepStart(request);
      state = state.copyWith(startSleep: AsyncValue.data(response));

      _ref.read(reportIdNotifierProvider.notifier).set(response.reportId);

      return true;
    } catch (e, st) {
      state = state.copyWith(startSleep: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> endSleep(SleepEndRequest request) async {
    state = state.copyWith(endSleep: const AsyncValue.loading());
    try {
      final response = await _repository.postSleepEnd(request);
      state = state.copyWith(endSleep: AsyncValue.data(response));
      return response.isValidReport;
    } catch (e, st) {
      state = state.copyWith(endSleep: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<void> sendSound(SleepSoundRequest request) async {
    state = state.copyWith(sound: const AsyncValue.loading());
    try {
      final response = await _repository.postSleepSound(request);
      state = state.copyWith(sound: AsyncValue.data(response));
    } catch (e, st) {
      state = state.copyWith(sound: AsyncValue.error(e, st));
    }
  }
}

class SleepModeState {
  final AsyncValue<SleepStartResponse?> startSleep;
  final AsyncValue<SleepEndResponse?> endSleep;
  final AsyncValue<SleepSoundResponse?> sound;

  const SleepModeState({
    required this.startSleep,
    required this.endSleep,
    required this.sound,
  });

  factory SleepModeState.initial() => const SleepModeState(
    startSleep: AsyncValue.data(null),
    endSleep: AsyncValue.data(null),
    sound: AsyncValue.data(null),
  );

  SleepModeState copyWith({
    AsyncValue<SleepStartResponse?>? startSleep,
    AsyncValue<SleepEndResponse?>? endSleep,
    AsyncValue<SleepSoundResponse?>? sound,
  }) {
    return SleepModeState(
      startSleep: startSleep ?? this.startSleep,
      endSleep: endSleep ?? this.endSleep,
      sound: sound ?? this.sound,
    );
  }
}
