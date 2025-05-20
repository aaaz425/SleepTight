import '../enums/music_category.dart';
import 'music_response.dart';

/// Grouped music list by category.
class MusicsByCategory {
  final MusicCategory category;
  final List<MusicResponse> musics;

  MusicsByCategory({required this.category, required this.musics});

  factory MusicsByCategory.fromJson(Map<String, dynamic> json) =>
      MusicsByCategory(
        category: MusicCategory.values.firstWhere(
          (e) => e.name == json['category'],
        ),
        musics:
            (json['musics'] as List<dynamic>)
                .map((e) => MusicResponse.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
    'category': category.name,
    'musics': musics.map((e) => e.toJson()).toList(),
  };
}
