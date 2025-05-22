import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/features/music/data/datasources/music_remote_data_source.dart';
import 'package:sleep_tight/features/music/data/models/enums/music_category.dart';
import 'package:sleep_tight/features/music/data/repositories/music_repository_impl.dart';
import 'package:sleep_tight/features/music/domain/entity/music_model.dart';
import 'package:sleep_tight/features/music/domain/repositories/music_repository.dart';

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  final remoteDataSource = ref.watch(musicRemoteDataSourceProvider);
  return MusicRepositoryImpl(remoteDataSource);
});

// 카테고리별로 독립된 FutureProvider
final musicsByCategoryProvider =
    FutureProvider.family<List<MusicModel>, MusicCategory>((
      ref,
      category,
    ) async {
      final repo = ref.watch(musicRepositoryProvider);
      final responses = await repo.getMusicsByCategory(category);
      return responses.map((r) => MusicModel.fromJson(r.toJson())).toList();
    });
