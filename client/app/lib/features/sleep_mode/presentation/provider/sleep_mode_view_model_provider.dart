import 'package:app/features/sleep_mode/domain/providers/sleep_mode_repository_provider.dart';
import 'package:app/features/sleep_mode/presentation/view_models/sleep_mode_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sleepModeViewModelProvider =
    StateNotifierProvider<SleepModeViewModel, SleepModeState>((ref) {
      final repository = ref.watch(sleepModeRepositoryProvider);
      return SleepModeViewModel(repository, ref);
    });
