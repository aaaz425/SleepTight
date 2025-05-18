enum Gender {
  male(en: 'Male', ko: '남성'),
  female(en: 'Female', ko: '여성');

  final String en;
  final String ko;

  const Gender({required this.en, required this.ko});

  // API에서 사용하는 문자열 값을 반환하는 getter
  String get toJson => en;

  // API 응답 문자열로부터 Gender enum 값을 가져오는 factory 생성자
  static Gender? fromJson(String? value) {
    if (value == null) return null;
    for (final gender in values) {
      if (gender.en.toLowerCase() == value.toLowerCase()) {
        // 대소문자 구분 없이 비교 (API 응답이 일관되지 않을 경우 유용)
        // 또는 gender.en == value 로 정확히 일치하는지 비교
        return gender;
      }
    }
    // 알려지지 않은 값에 대한 처리 (예: 기본값 반환 또는 null 반환)
    print('Warning: Unknown Gender string value encountered: $value');
    return null;
  }
}
