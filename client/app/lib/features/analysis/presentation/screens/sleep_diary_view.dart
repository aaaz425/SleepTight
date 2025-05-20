import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/analysis/data/models/enums/wake_awareness.dart';
import 'package:sleep_tight/features/analysis/data/models/enums/wake_method.dart';
import 'package:sleep_tight/features/analysis/presentation/providers/sleep_diary_provider.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';
import 'package:sleep_tight/shared/widgets/custom_radio_group.dart';
import 'package:sleep_tight/shared/widgets/custom_text_field.dart';

class SleepDiaryView extends ConsumerStatefulWidget {
  final int reportId;

  const SleepDiaryView({super.key, required this.reportId});

  @override
  ConsumerState<SleepDiaryView> createState() => _SleepDiaryViewState();
}

class _SleepDiaryViewState extends ConsumerState<SleepDiaryView> {
  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final min = int.parse(parts[1]);
    final period = hour >= 12 ? '오후' : '오전';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$period $displayHour:${min.toString().padLeft(2, '0')}';
  }

  // 'HH:mm:ss'에서 분만 안전하게 파싱해 'X분'으로 반환
  String _formatLatency(String latency) {
    final parts = latency.split(':');
    final min = (parts.length > 1) ? int.tryParse(parts[1]) ?? 0 : 0;
    return '$min 분';
  }

  // 폼 상태 관리
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditMode = false;
  bool _isFormValid = false;
  bool _isFormChanged = false;
  bool _isWakeMethodOtherSelected = false;

  // 폼 변경 시 상태 업데이트
  // void _onFormChanged() {
  //   final fs = _formKey.currentState;
  //   setState(() {
  //     _isFormValid = fs?.isValid ?? false;
  //     _isFormChanged = fs?.isChanged ?? false;
  //     _isWakeMethodOtherSelected =
  //         fs?.fields['wakeMethod']?.value == WakeMethod.other;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final diaryAsync = ref.watch(sleepDiaryByIdProvider(widget.reportId));

    return diaryAsync.when(
      data: (diary) {
        // 일지 작성 전 화면
        if (_isEditMode == false) {
          return Center(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/pillow_sleep.png',
                          width: 160,
                          height: 160,
                        ),
                        SizedBox(height: 19),
                        Text(
                          '작성된 수면일지가 없습니다.',
                          style: AppTextStyles.bodyB1Rg(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12,
                  ),
                  child: CustomButton(
                    onPressed: () {
                      setState(() {
                        _isEditMode = true;
                      });
                    },
                    height: 48,
                    text: '수면일지 작성하기',
                    theme: 'gray',
                  ),
                ),
              ],
            ),
          );
        } else {
          return FormBuilder(
            key: _formKey,
            // onChanged: _onFormChanged,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 스크롤 영역(헤더 포함)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 헤더: Center와 RichText
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: AppTextStyles.titleT3Rg(
                                  color: AppColors.white,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        '${DateTime.parse(diary.sleepDate).month}월 ${DateTime.parse(diary.sleepDate).day}일에는 총 ',
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Text(
                                      _calculateSleepDurationInMinutes(
                                        diary.sleepTime,
                                        diary.wakeTime,
                                      ),
                                      style: AppTextStyles.titleT1Sb(
                                        color: AppColors.sub1,
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' 동안 잤습니다.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.gray02,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _SummaryHeader(
                                            title: '취침 시간',
                                            isEdit: true,
                                          ),
                                          Text(
                                            _formatTime(diary.sleepTime),
                                            style: AppTextStyles.titleT3Sb(
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _SummaryHeader(
                                            title: '기상 시간',
                                            isEdit: true,
                                          ),
                                          Text(
                                            _formatTime(diary.wakeTime),
                                            style: AppTextStyles.titleT3Sb(
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _SummaryHeader(
                                            title: '자다 깬 횟수',
                                            isEdit: true,
                                          ),
                                          Text(
                                            "${diary.wakeCount ?? 0} 번",
                                            style: AppTextStyles.titleT3Sb(
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                      width: 120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _SummaryHeader(
                                            title: '잠드는 데 걸린 시간',
                                            isEdit: false,
                                          ),
                                          Text(
                                            _formatLatency(diary.sleepLatency),
                                            style: AppTextStyles.titleT3Sb(
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _QuestionHeader(title: '수면의 질은 어땠나요?'),
                              CustomRadioGroup(
                                direction: Axis.vertical,
                                name: 'sleepQuality',
                                options: [1, 2, 3, 4, 5, 6, 7],
                                labels: [
                                  '매우 나쁨',
                                  '나쁨',
                                  '조금 나쁨',
                                  '보통',
                                  '조금 좋음',
                                  '좋음',
                                  '매우 좋음',
                                ],
                              ),
                              SizedBox(height: 12),
                              _QuestionHeader(title: '기상 후 기분은 어떠신가요? '),
                              CustomRadioGroup(
                                direction: Axis.vertical,
                                name: 'moodScore',
                                options: [1, 2, 3, 4, 5, 6, 7],
                                labels: [
                                  '매우 나쁨',
                                  '나쁨',
                                  '조금 나쁨',
                                  '보통',
                                  '조금 좋음',
                                  '좋음',
                                  '매우 좋음',
                                ],
                              ),
                              SizedBox(height: 12),
                              _QuestionHeader(title: '잠은 다 깨셨나요?'),
                              CustomRadioGroup(
                                direction: Axis.vertical,
                                name: 'wakeAwareness',
                                options: [
                                  WakeAwareness.no,
                                  WakeAwareness.normal,
                                  WakeAwareness.yes,
                                ],
                                labels: ['아니오', '보통', '네'],
                              ),
                              SizedBox(height: 12),
                              _QuestionHeader(title: '어떻게 일어나셨나요?'),
                              CustomRadioGroup(
                                direction: Axis.vertical,
                                name: 'wakeMethod',
                                options: [
                                  WakeMethod.alarm,
                                  WakeMethod.byPerson,
                                  WakeMethod.self,
                                  WakeMethod.noise,
                                  WakeMethod.other,
                                ],
                                labels: ['알람', '누군가 깨움', '스스로 일어남', '소음', '기타'],
                              ),
                              Builder(
                                builder: (context) {
                                  final selected =
                                      FormBuilder.of(
                                        context,
                                      )?.fields['wakeMethod']?.value;
                                  if (selected == WakeMethod.other) {
                                    return Column(
                                      children: [
                                        SizedBox(height: 8),
                                        CustomTextField(
                                          name: 'wakeMethodEtc',
                                          hintText: '내용을 입력해주세요.',
                                        ),
                                      ],
                                    );
                                  }
                                  return SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 푸터 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12,
                  ),
                  child: CustomButton(
                    onPressed: () {
                      setState(() {
                        _isEditMode = false;
                      });
                    },
                    height: 48,
                    text: '완료',
                    theme: 'gray',
                  ),
                ),
              ],
            ),
          );
        }
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('오류: $e'),
    );
  }
}

// 질문 헤더 위젯
class _QuestionHeader extends StatelessWidget {
  final String title;

  const _QuestionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: AppTextStyles.titleT3Rg(color: AppColors.white),
      ),
    );
  }
}

// 요약 헤더 위젯
class _SummaryHeader extends StatelessWidget {
  final String title;
  final bool isEdit;

  const _SummaryHeader({required this.title, required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyB2Rg(color: AppColors.font2)),
          if (isEdit)
            GestureDetector(
              onTap: () {
                debugPrint('$title 버튼 클릭');
              },
              child: SvgPicture.asset(
                'assets/icons/pencil.svg',
                width: 16,
                height: 16,
              ),
            ),
        ],
      ),
    );
  }
}

/// 총 수면시간(분)을 계산하여 반환합니다.
String _calculateSleepDurationInMinutes(String sleepTime, String wakeTime) {
  final s = sleepTime.split(':').map(int.parse).toList();
  final w = wakeTime.split(':').map(int.parse).toList();
  int start = s[0] * 60 + s[1];
  int end = w[0] * 60 + w[1];
  int diff = end - start;
  if (diff < 0) diff += 24 * 60; // 자정 넘김 보정
  final hours = diff ~/ 60;
  final minutes = diff % 60;
  if (hours == 0) return '$minutes분';
  if (minutes == 0) return '$hours시간';
  return '$hours시간 $minutes분';
}
