import 'package:flutter/material.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_report.dart';

class SleepStageLineChart extends StatelessWidget {
  final List<SleepStage> stages;

  const SleepStageLineChart({super.key, required this.stages});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: CustomPaint(painter: _SleepStageChartPainter(stages)),
    );
  }
}

class _SleepStageChartPainter extends CustomPainter {
  final List<SleepStage> stages;

  _SleepStageChartPainter(this.stages);

  static const Map<String, double> stageToY = {
    'AWAKE': 3,
    'REM': 1,
    'LIGHT': 2,
    'DEEP': 0,
  };

  static const Map<String, Color> sleepStageColor = {
    'AWAKE': AppColors.pink,
    'REM': AppColors.pink,
    'LIGHT': AppColors.pink,
    'DEEP': AppColors.pink,
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (stages.isEmpty) return;

    final baseTime = stages.first.startTime;
    final endTime = stages.last.endTime;
    final totalMinutes = endTime.difference(baseTime).inMinutes;
    final totalDuration = stages.last.endTime.difference(baseTime).inMinutes;

    final double labelHeight = 20; // 라벨 표시 영역
    final double chartHeight = size.height - labelHeight;
    final double chartWidth = size.width;

    Offset pointFor(SleepStage s) {
      final minutes = s.startTime.difference(baseTime).inMinutes;
      final x = (minutes / totalDuration) * chartWidth;
      final yLevel = stageToY[s.stageType] ?? 0;
      final y = (3 - yLevel) / 3 * chartHeight; // 0=top, 3=bottom
      return Offset(x, y);
    }

    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      final next = (i + 1 < stages.length) ? stages[i + 1] : null;

      final start = pointFor(stage);
      final end = next != null ? pointFor(next) : Offset(chartWidth, start.dy);

      final paint =
          Paint()
            ..color = sleepStageColor[stage.stageType] ?? Colors.grey
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

      canvas.drawLine(start, end, paint);
    }

    final textStyle = TextStyle(color: AppColors.font2, fontSize: 11);

    // 시작 시간 라벨
    final startLabel =
        '${baseTime.hour.toString().padLeft(2, '0')}:${baseTime.minute.toString().padLeft(2, '0')}';
    final startTp = TextPainter(
      text: TextSpan(text: startLabel, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    startTp.paint(canvas, Offset(0 - startTp.width / 2, chartHeight + 2));

    // 중간 라벨 (짝수 기준 시간 기준으로 위치 계산)
    final startHour = baseTime.hour;
    final endHour = endTime.hour;

    for (int h = startHour + 1; h <= endHour; h++) {
      if (h % 2 != 0) continue; // 짝수만

      // 라벨 시간
      final current = DateTime(baseTime.year, baseTime.month, baseTime.day, h);

      // x 위치: current 시간 기준으로 몇 분 차이인지 계산
      final diffMin = current.difference(baseTime).inMinutes;
      final x = (diffMin / totalMinutes) * chartWidth;

      final label =
          '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}';

      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(x - tp.width / 2, chartHeight + 2)); // 여유 간격
    }

    // 종료 시간 라벨
    final endLabel =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    final endTp = TextPainter(
      text: TextSpan(text: endLabel, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    endTp.paint(canvas, Offset(chartWidth - endTp.width / 2, chartHeight + 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
