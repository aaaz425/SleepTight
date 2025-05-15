import 'package:app/core/network/dio_provider.dart';
import 'package:app/features/sleep_mode/data/datasources/sleep_mode_datasource.dart';
import 'package:app/features/sleep_mode/data/repositories/sleep_mode_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sleepModeRepositoryProvider = Provider<SleepModeRepositoryImpl>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  final datasource = SleepModeDatasource(dio);
  return SleepModeRepositoryImpl(datasource);
});
