enum ActivityDataType { water, momentum, walk, caffeine }

// 문자열 → enum 변환
extension ActivityDataTypeParser on String {
  ActivityDataType toActivityDataType() {
    switch (toUpperCase()) {
      case 'WATER':
        return ActivityDataType.water;
      case 'MOMENTUM':
        return ActivityDataType.momentum;
      case 'WALK':
        return ActivityDataType.walk;
      case 'CAFFEINE':
        return ActivityDataType.caffeine;
      default:
        return ActivityDataType.caffeine;
    }
  }
}

// enum → 짧은 라벨 반환
extension ActivityDataTypeLabel on ActivityDataType {
  String toShortLabel() {
    switch (this) {
      case ActivityDataType.water:
        return '수분 섭취';
      case ActivityDataType.momentum:
        return '에너지 소비량';
      case ActivityDataType.walk:
        return '걸음 수';
      case ActivityDataType.caffeine:
        return '카페인';
    }
  }
}
