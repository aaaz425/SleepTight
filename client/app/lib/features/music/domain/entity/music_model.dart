class MusicModel {
  final String id; // 고유 식별자
  final String title; // 곡 제목
  // final String category; // 음악 카테고리 (API 응답 필드 직접 사용)
  final String coverUrl; // 앨범 아트 또는 커버 이미지 URL (API 응답 필드 직접 사용)
  final String streamUrl; // 실제 오디오 스트림 URL (API 응답 필드 직접 사용)
  // final bool isLiked; // 현재 사용자의 '좋아요' 여부
  // final int likeCount; // '좋아요' 수

  MusicModel({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.streamUrl,
  });

  // JSON으로부터 MusicModel 객체를 생성하는 factory 생성자
  factory MusicModel.fromJson(Map<String, dynamic> json) {
    return MusicModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      coverUrl: json['coverUrl'] as String, // API에서 항상 제공된다고 가정 (required이므로)
      streamUrl: json['streamUrl'] as String,
    );
  }

  // UI나 로직에서 일관된 이름을 사용하고 싶을 경우를 위한 getter (선택 사항)
  // 예를 들어, 다른 곳에서 albumArtUrl이라는 이름을 사용했다면:
  String get albumArtUrl => coverUrl;
  // 오디오 URL도 마찬가지:
  String get audioUrl => streamUrl;

  // toJson 메소드 (필요시)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverUrl': coverUrl,
      'streamUrl': streamUrl,
    };
  }
}
