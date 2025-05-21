import 'package:flutter/material.dart';
import 'package:sleep_chart/sleep_chart.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_report_model.dart';

class SleepStageLineChartTest extends StatelessWidget {
  const SleepStageLineChartTest({
    super.key,
    required this.sleepData,
    required this.sleepStartTime,
    required this.sleepEndTime,
  });

  final List<SleepStageModel> sleepData;
  final DateTime sleepStartTime;
  final DateTime sleepEndTime;

  // enum SleepStage {
  //   light, // 浅睡 (mode=1)
  //   deep, // 深睡 (mode=2)
  //   awake, // 清醒 (mode=3)
  //   notWorn, // 未佩戴 (mode=4)
  //   rem, // 快速眼动 (mode=5)
  //   unknown, // 其他未知状态
  // }

  List<SleepDetailChart> _convertToSleepDetailChart() {
    debugPrint('sleepData: $sleepData');
    return sleepData
        .map(
          (e) => SleepDetailChart(
            model: SleepStage.values.firstWhere(
              (element) =>
                  element.name.toLowerCase() == e.stageType.toLowerCase(),
            ),
            width: e.duration.toDouble(),
            startTime: e.startTime,
            endTime: e.endTime,
            duration: e.duration,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SleepDurationChartWidget(
      heightUnit: 1 / 8,
      titleHeight: 45,
      titleGap: 10,
      bgColor: Color.fromRGBO(72, 112, 243, 0.04),
      details: _convertToSleepDetailChart(),
      startTime: sleepStartTime,
      endTime: sleepEndTime,
      xAxisTitleOffset: 0,
      xAxisTitleHeight: 100,
    );
  }
}
/**
 * 
 *   final List<SleepStageModel> stages;
 *  [
                {
                    "stageType": "AWAKE",
                    "startTime": "2025-05-21T14:00:00.000Z",
                    "endTime": "2025-05-21T14:10:00.000Z",
                    "duration": 5
                },
                {
                    "stageType": "REM",
                    "startTime": "2025-05-21T14:10:00.000Z",
                    "endTime": "2025-05-21T14:25:00.000Z",
                    "duration": 15
                },
                {
                    "stageType": "REM",
                    "startTime": "2025-05-21T14:25:00.000Z",
                    "endTime": "2025-05-21T14:40:00.000Z",
                    "duration": 15
                },
                {
                    "stageType": "REM",
                    "startTime": "2025-05-21T14:40:00.000Z",
                    "endTime": "2025-05-21T14:55:00.000Z",
                    "duration": 15
                },
                {
                    "stageType": "LIGHT",
                    "startTime": "2025-05-21T14:55:00.000Z",
                    "endTime": "2025-05-21T15:20:00.000Z",
                    "duration": 25
                },
                {
                    "stageType": "LIGHT",
                    "startTime": "2025-05-21T15:20:00.000Z",
                    "endTime": "2025-05-21T15:45:00.000Z",
                    "duration": 25
                },
                {
                    "stageType": "LIGHT",
                    "startTime": "2025-05-21T15:45:00.000Z",
                    "endTime": "2025-05-21T16:15:00.000Z",
                    "duration": 30
                },
                {
                    "stageType": "DEEP",
                    "startTime": "2025-05-21T16:15:00.000Z",
                    "endTime": "2025-05-21T16:45:00.000Z",
                    "duration": 30
                },
                {
                    "stageType": "AWAKE",
                    "startTime": "2025-05-21T16:45:00.000Z",
                    "endTime": "2025-05-21T16:55:00.000Z",
                    "duration": 10
                },
                {
                    "stageType": "REM",
                    "startTime": "2025-05-21T16:55:00.000Z",
                    "endTime": "2025-05-21T17:10:00.000Z",
                    "duration": 15
                },
                {
                    "stageType": "LIGHT",
                    "startTime": "2025-05-21T17:10:00.000Z",
                    "endTime": "2025-05-21T17:35:00.000Z",
                    "duration": 25
                },
                {
                    "stageType": "LIGHT",
                    "startTime": "2025-05-21T17:35:00.000Z",
                    "endTime": "2025-05-21T18:05:00.000Z",
                    "duration": 30
                },
                {
                    "stageType": "LIGHT",
                    "startTime": "2025-05-21T18:05:00.000Z",
                    "endTime": "2025-05-21T18:15:00.000Z",
                    "duration": 10
                },
                {
                    "stageType": "DEEP",
                    "startTime": "2025-05-21T18:15:00.000Z",
                    "endTime": "2025-05-21T18:30:00.000Z",
                    "duration": 15
                },
                {
                    "stageType": "DEEP",
                    "startTime": "2025-05-21T18:30:00.000Z",
                    "endTime": "2025-05-21T18:45:00.000Z",
                    "duration": 15
                },
                {
                    "stageType": "DEEP",
                    "startTime": "2025-05-21T18:45:00.000Z",
                    "endTime": "2025-05-21T19:10:00.000Z",
                    "duration": 25
                },
                {
                    "stageType": "DEEP",
                    "startTime": "2025-05-21T19:10:00.000Z",
                    "endTime": "2025-05-21T19:40:00.000Z",
                    "duration": 30
                },
                {
                    "stageType": "LIGHT",
                    "startTime": "2025-05-21T19:40:00.000Z",
                    "endTime": "2025-05-21T19:50:00.000Z",
                    "duration": 10
                },
                {
                    "stageType": "LIGHT",
                    "startTime": "2025-05-21T19:50:00.000Z",
                    "endTime": "2025-05-21T20:05:00.000Z",
                    "duration": 15
                },
                {
                    "stageType": "LIGHT",
                    "startTime": "2025-05-21T20:05:00.000Z",
                    "endTime": "2025-05-21T20:25:00.000Z",
                    "duration": 20
                },
                {
                    "stageType": "LIGHT",
                    "startTime": "2025-05-21T20:25:00.000Z",
                    "endTime": "2025-05-21T20:45:00.000Z",
                    "duration": 20
                },
                {
                    "stageType": "DEEP",
                    "startTime": "2025-05-21T20:45:00.000Z",
                    "endTime": "2025-05-21T20:55:00.000Z",
                    "duration": 10
                },
                {
                    "stageType": "LIGHT",
                    "startTime": "2025-05-21T20:55:00.000Z",
                    "endTime": "2025-05-21T21:00:00.000Z",
                    "duration": 5
                },
                {
                    "stageType": "REM",
                    "startTime": "2025-05-21T21:00:00.000Z",
                    "endTime": "2025-05-21T21:05:00.000Z",
                    "duration": 5
                },
                {
                    "stageType": "REM",
                    "startTime": "2025-05-21T21:05:00.000Z",
                    "endTime": "2025-05-21T21:10:00.000Z",
                    "duration": 5
                }
            ]
 */