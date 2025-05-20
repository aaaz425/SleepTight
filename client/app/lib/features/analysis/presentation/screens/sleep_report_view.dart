import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_report.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/page_indicator.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/sleep_sound.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/sleep_stage_line_chart.dart';

class SleepReportView extends StatefulWidget {
  final List<SleepReport> reports;
  final void Function(int)? onPageChanged;

  const SleepReportView({super.key, required this.reports, this.onPageChanged});

  @override
  State<SleepReportView> createState() => _SleepReportViewState();
}

class _SleepReportViewState extends State<SleepReportView> {
  int _currentIndex = 0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration parseDuration(Map<String, dynamic>? json) {
    if (json == null) return Duration.zero;
    return Duration(hours: json['hours'] ?? 0, minutes: json['minutes'] ?? 0);
  }

  String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0 && m == 0) return '-';
    if (h == 0) return '${m}분';
    if (m == 0) return '${h}시간';
    return '${h}시간 ${m}분';
  }

  String formatPercent(Duration part, Duration total) {
    if (total.inMinutes == 0) return '-';
    final percent = (part.inMinutes / total.inMinutes * 100).round();
    return '$percent%';
  }

  String formatTime(DateTime? time) {
    if (time == null) return '-';
    return DateFormat('a hh:mm', 'ko').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.reports.length,
                onPageChanged: (i) {
                  setState(() => _currentIndex = i);
                  widget.onPageChanged?.call(i);
                },
                itemBuilder: (context, index) {
                  final report = widget.reports[index];
                  final stages = report.sleepStages;
                  final isStagesEmpty = stages.isEmpty;

                  final latency = report.sleepLatency ?? Duration.zero;
                  final awake = report.totalAwakeTime ?? Duration.zero;
                  final light = report.totalLightSleepTime ?? Duration.zero;
                  final deep = report.totalDeepSleepTime ?? Duration.zero;
                  final rem = report.totalRemSleepTime ?? Duration.zero;
                  final awakenCount = report.awakenCount ?? 0;

                  final totalSleep = light + deep + rem;
                  final durationInBed = report.sleepEndTime.difference(
                    report.sleepStartTime,
                  );

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '${DateFormat('M월 d일', 'ko').format(report.sleepStartTime)}에는 총 ',
                                ),
                                TextSpan(
                                  text: formatDuration(totalSleep),
                                  style: const TextStyle(
                                    color: AppColors.sub1,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: ' 동안 잤습니다.'),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 20,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.gray02,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _buildTimeColumn(
                                      '취침 시간',
                                      formatTime(report.sleepStartTime),
                                    ),
                                    _buildTimeColumn(
                                      '기상 시간',
                                      formatTime(report.sleepEndTime),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildLabelRow(
                                  '누워 있던 시간',
                                  formatDuration(durationInBed),
                                ),
                                const SizedBox(height: 4),
                                _buildLabelRow(
                                  '실제 수면 시간',
                                  formatDuration(totalSleep),
                                ),
                                const SizedBox(height: 4),
                                _buildLabelRow(
                                  '잠드는 데 걸린 시간',
                                  formatDuration(latency),
                                ),
                                const SizedBox(height: 4),
                                _buildLabelRow('잠에서 깬 횟수', '${awakenCount}회'),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '수면 단계',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              isStagesEmpty
                                  ? const Text(
                                    '수면 단계 데이터가 없습니다.',
                                    style: TextStyle(color: AppColors.font2),
                                  )
                                  : SizedBox(
                                    height: 100,
                                    child: SleepStageLineChart(stages: stages),
                                  ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/clock.svg',
                                    width: 20,
                                    height: 20,
                                    color: AppColors.gray07,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '수면 단계별 시간',
                                    style: TextStyle(
                                      color: AppColors.font1,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _buildStageCard(
                                awake: awake,
                                rem: rem,
                                light: light,
                                deep: deep,
                                totalSleep: totalSleep,
                                formatDuration: formatDuration,
                                formatPercent: formatPercent,
                              ),
                            ],
                          ),
                        ),
                        const SleepSound(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: PageIndicator(
            total: widget.reports.length,
            current: _currentIndex,
            onChanged: (index) {
              _controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() => _currentIndex = index);
              widget.onPageChanged?.call(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.font2, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: AppColors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.font2, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(color: AppColors.sub1, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildStageCard({
    required Duration awake,
    required Duration rem,
    required Duration light,
    required Duration deep,
    required Duration totalSleep,
    required String Function(Duration) formatDuration,
    required String Function(Duration, Duration) formatPercent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray02,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStageRow(
            '비수면',
            AppColors.white,
            awake,
            totalSleep,
            formatDuration,
            formatPercent,
          ),
          const SizedBox(height: 12),
          _buildStageRow(
            '렘수면',
            AppColors.sub2,
            rem,
            totalSleep,
            formatDuration,
            formatPercent,
          ),
          const SizedBox(height: 12),
          _buildStageRow(
            '얕은 수면',
            AppColors.sub1,
            light,
            totalSleep,
            formatDuration,
            formatPercent,
          ),
          const SizedBox(height: 12),
          _buildStageRow(
            '깊은 수면',
            AppColors.sub1Vr,
            deep,
            totalSleep,
            formatDuration,
            formatPercent,
          ),
        ],
      ),
    );
  }

  Widget _buildStageRow(
    String label,
    Color color,
    Duration duration,
    Duration total,
    String Function(Duration) formatDuration,
    String Function(Duration, Duration) formatPercent,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: AppColors.font2, fontSize: 12),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatPercent(duration, total),
              style: TextStyle(color: color, fontSize: 16),
            ),
            Text(
              formatDuration(duration),
              style: const TextStyle(color: AppColors.font2, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
