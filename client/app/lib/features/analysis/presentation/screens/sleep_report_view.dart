import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_report_model.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/page_indicator.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/sleep_sound.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/sleep_stage_line_chart.dart';

class SleepReportView extends StatefulWidget {
  final List<SleepReportModel> reports;
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
    if (h == 0) return '$m분';
    if (m == 0) return '$h시간';
    return '$h시간 $m분';
  }

  String formatPercent(Duration part, Duration total) {
    if (total.inMinutes == 0) return '-';
    final percent = (part.inMinutes / total.inMinutes * 100).round();
    return '$percent%';
  }

  String formatTime(DateTime? time) {
    if (time == null) return '-';
    final formatted = DateFormat('a hh:mm', 'en').format(time);
    return formatted.replaceFirst('AM', '오전').replaceFirst('PM', '오후');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                              style: TextStyle(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            _buildLabelRow('잠에서 깬 횟수', '$awakenCount회'),
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
                              ? SizedBox(
                                height: 100,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // 블러 적용된 이미지
                                    ClipRect(
                                      child: ImageFiltered(
                                        imageFilter: ImageFilter.blur(
                                          sigmaX: 2,
                                          sigmaY: 2,
                                        ),
                                        child: Image.asset(
                                          'assets/images/sleep_stage_sample.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),

                                    // 텍스트는 블러 바깥
                                    const Center(
                                      child: Text(
                                        '수면 단계를 분석하려면 수면 시 웨어러블 기기를 착용하셔야 합니다',
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : SizedBox(
                                height: 100,
                                child: SleepStageLineChart(stages: stages),
                              ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10,
                      ),
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
                    SleepSound(reportId: report.sleepReportId),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.reports.length > 1)
          PageIndicator(
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
      ],
    );
  }

  Widget _buildTimeColumn(String label, String value) {
    return SizedBox(
      width: 120,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStageColumn(
                '비수면',
                AppColors.white,
                awake,
                totalSleep,
                formatDuration,
                formatPercent,
              ),
              _buildStageColumn(
                '렘수면',
                AppColors.sub2,
                rem,
                totalSleep,
                formatDuration,
                formatPercent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              _buildStageColumn(
                '얕은 수면',
                AppColors.sub1,
                light,
                totalSleep,
                formatDuration,
                formatPercent,
              ),
              _buildStageColumn(
                '깊은 수면',
                AppColors.sub1Vr,
                deep,
                totalSleep,
                formatDuration,
                formatPercent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageColumn(
    String label,
    Color color,
    Duration duration,
    Duration total,
    String Function(Duration) formatDuration,
    String Function(Duration, Duration) formatPercent,
  ) {
    return SizedBox(
      width: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                label,
                style: AppTextStyles.bodyB4Rg(color: AppColors.font2),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Text(
            formatPercent(duration, total),
            style: AppTextStyles.titleT3Sb(color: color),
          ),
          Text(
            formatDuration(duration),
            style: AppTextStyles.bodyB2Rg(color: AppColors.font2),
          ),
        ],
      ),
    );
  }
}
