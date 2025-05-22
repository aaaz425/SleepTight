import 'package:sleep_tight/features/coach/data/models/sleep_coach_type_enum.dart';

final Map<ActivityDataType, Map<String, dynamic>> activityMeta = {
  ActivityDataType.water: {
    'title': '수분 섭취량',
    'image': 'assets/images/water.png',
    'unit': 'ml',
  },
  ActivityDataType.momentum: {
    'title': '에너지 소비',
    'image': 'assets/images/momentum.jpg',
    'unit': 'kcal',
  },
  ActivityDataType.walk: {
    'title': '걸음 수',
    'image': 'assets/images/walk.png',
    'unit': '보',
  },
  ActivityDataType.caffeine: {
    'title': '카페인 섭취',
    'image': 'assets/images/caffeine.jpg',
    'unit': 'mg',
  },
};
