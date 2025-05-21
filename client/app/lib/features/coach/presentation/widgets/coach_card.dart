import 'package:flutter/material.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/coach/data/models/sleep_coach_meta.dart';
import 'package:sleep_tight/features/coach/data/models/sleep_coach_model.dart';
import 'package:sleep_tight/features/coach/data/models/sleep_coach_type_enum.dart';
import 'package:intl/intl.dart';

class CoachingCard extends StatelessWidget {
  final SleepCoachModel item;

  const CoachingCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final meta = activityMeta[item.activity]!;
    final imageUrl = meta['image'] as String;
    final title = item.activity.toShortLabel();
    final unit = meta['unit'] as String;

    final value = item.value;
    final target = item.target;
    final progress = (value / target).clamp(0.0, 1.0);
    final formattedValue = NumberFormat('#,##0.##').format(value);
    final formattedTarget = NumberFormat('#,##0.##').format(target);
    final percent = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              // 이미지
              Image.asset(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),

              // 투명도 그라디언트 오버레이
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000), // 투명
                      Color(0xE6000000), // 불투명한 검정 (투명도 90%)
                    ],
                  ),
                ),
              ),

              // 설명 텍스트
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  item.description,
                  style: AppTextStyles.bodyB5Rg(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // 항목 이름 진행률 바
        Row(
          children: [
            Text(title, style: AppTextStyles.bodyB4Rg(color: AppColors.font2)),
            const SizedBox(width: 4),
            SizedBox(
              width: 80,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.gray03,
                color: AppColors.accessibleBlue,
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),

        // 퍼센트
        Text(
          '$percent%',
          style: AppTextStyles.titleT3Sb(color: AppColors.white),
        ),

        const SizedBox(height: 4),

        // 수치 정보
        Text(
          '$formattedValue$unit / $formattedTarget$unit',
          style: AppTextStyles.bodyB2Rg(color: AppColors.font2),
        ),
      ],
    );
  }
}
