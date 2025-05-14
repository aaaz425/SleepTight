import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/core/storage/secure_storage_provider.dart';
import 'package:sleep_tight/core/storage/shared_preferences_provider.dart';
import 'package:sleep_tight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sleep_tight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sleep_tight/features/auth/data/models/enums/auth_status.dart';
import 'package:sleep_tight/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sleep_tight/features/auth/domain/entities/auth_state.dart';
import 'package:sleep_tight/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final prefs = ref.watch(sharedPreferencesProvider);

  final remote = AuthRemoteDataSourceImpl(dio: dioClient.dio);
  final local = AuthLocalDataSourceImpl(
    secureStorage: secureStorage,
    prefs: prefs,
  );
  return AuthRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repo);
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository repo;
  AuthStateNotifier(this.repo) : super(AuthState.initial()) {
    _init();
  }

  Future<void> _init() async {
    final statusString = await repo.getStatus();
    final status = AuthStatus.fromString(statusString);
    state = AuthState(status: status);
  }

  Future<void> refreshAuthStatus() async {
    final statusString = await repo.getStatus();
    final status = AuthStatus.fromString(statusString);
    state = AuthState(status: status);
  }
}
