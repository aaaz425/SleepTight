import 'package:flutter/material.dart';
import 'package:sleep_tight/features/coach/presentation/provider/sleep_coach.dart';

class CoachingCard extends StatelessWidget {
  final SleepCoachingItem item;

  const CoachingCard({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    final icon = _activityIcon(item.activity);
    final title = _activityTitle(item.activity);
    final valueStr = '${item.value}${_unit(item.activity)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                Text(
                  valueStr,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.description, style: TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  // 아이콘 매핑
  Widget _activityIcon(String activity) {
    switch (activity) {
      case 'water_intake':
        return Icon(Icons.local_drink, color: Colors.blueAccent, size: 30);
      case 'step_count':
        return Icon(Icons.directions_walk, color: Colors.greenAccent, size: 30);
      case 'caffeine':
        return Icon(Icons.coffee, color: Colors.brown, size: 30);
      default:
        return Icon(Icons.help_outline, color: Colors.grey, size: 30);
    }
  }

  // 제목 매핑
  String _activityTitle(String activity) {
    switch (activity) {
      case 'water_intake':
        return '수분 섭취';
      case 'step_count':
        return '걸음 수';
      case 'caffeine':
        return '카페인 섭취';
      default:
        return '기타';
    }
  }

  // 단위 매핑
  String _unit(String activity) {
    switch (activity) {
      case 'water_intake':
        return 'ml';
      case 'step_count':
        return '보';
      case 'caffeine':
        return 'mg';
      default:
        return '';
    }
  }
}
