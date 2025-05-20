import 'package:sleep_tight/features/music/data/models/enums/music_category.dart';

class MusicCategoryRequest {
  final MusicCategory category;

  MusicCategoryRequest({required this.category});

  factory MusicCategoryRequest.fromJson(Map<String, dynamic> json) =>
      MusicCategoryRequest(
        category: MusicCategory.values.firstWhere(
          (e) => e.name == json['category'],
        ),
      );

  Map<String, dynamic> toJson() => {'category': category.name};
}
