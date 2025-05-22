import '../enums/music_category.dart';

class MusicResponse {
  final int id;
  final String title;
  final MusicCategory category;
  final String coverUrl;
  final bool isLiked;
  final int likeCount;
  final String streamUrl;

  MusicResponse({
    required this.id,
    required this.title,
    required this.category,
    required this.coverUrl,
    required this.isLiked,
    required this.likeCount,
    required this.streamUrl,
  });

  factory MusicResponse.fromJson(Map<String, dynamic> json) => MusicResponse(
    id: json['id'] as int,
    title: json['title'] as String,
    category: MusicCategory.values.firstWhere(
      (e) => e.name == json['category'],
    ),
    coverUrl: json['coverUrl'] as String,
    isLiked: json['isLiked'] as bool,
    likeCount: json['likeCount'] as int,
    streamUrl: json['streamUrl'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category.name,
    'coverUrl': coverUrl,
    'isLiked': isLiked,
    'likeCount': likeCount,
    'streamUrl': streamUrl,
  };
}
