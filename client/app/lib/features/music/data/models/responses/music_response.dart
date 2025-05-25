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
    this.coverUrl = 'assets/images/album_example.png',
    required this.isLiked,
    required this.likeCount,
    this.streamUrl = 'assets/sound/music_example.mp3',
  });

  factory MusicResponse.fromJson(Map<String, dynamic> json) => MusicResponse(
    id: json['id'] as int,
    title: json['title'] as String,
    category: MusicCategory.values.firstWhere(
      (e) => e.name == json['category'],
    ),
    // coverUrl: json['coverUrl'] as String,
    isLiked: json['isLiked'] as bool,
    likeCount: json['likeCount'] as int,
    // streamUrl: json['streamUrl'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category.name,
    // 'coverUrl': coverUrl,
    'isLiked': isLiked,
    'likeCount': likeCount,
    // 'streamUrl': streamUrl,
  };
}
