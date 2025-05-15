import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/core/storage/secure_storage_provider.dart';
import 'package:sleep_tight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sleep_tight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sleep_tight/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sleep_tight/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  final remote = AuthRemoteDataSourceImpl(dio: dioClient.dio);
  final local = AuthLocalDataSourceImpl(secureStorage: secureStorage);
  return AuthRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});
