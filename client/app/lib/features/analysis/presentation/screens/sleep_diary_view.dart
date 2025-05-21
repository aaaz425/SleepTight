import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/analysis/data/models/enums/wake_awareness.dart';
import 'package:sleep_tight/features/analysis/data/models/enums/wake_method.dart';
import 'package:sleep_tight/features/analysis/data/models/requests/update_sleep_diary_request.dart';
import 'package:sleep_tight/features/analysis/domain/entity/sleep_diary_model.dart';
import 'package:sleep_tight/features/analysis/presentation/providers/sleep_diary_provider.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/wake_count_modal.dart';
import 'package:sleep_tight/features/coach/data/models/requests/create_sleep_coaching_request.dart';
import 'package:sleep_tight/features/coach/presentation/provider/sleep_coach.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';
import 'package:sleep_tight/shared/widgets/custom_radio_group.dart';
import 'package:sleep_tight/shared/widgets/custom_text_field.dart';
import 'package:sleep_tight/shared/widgets/custom_time_picker.dart';

// DateTime 확장: 오늘인지 확인하는 getter 추가
extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

class SleepDiaryView extends ConsumerStatefulWidget {
  final int reportId;

  const SleepDiaryView({super.key, required this.reportId});

  @override
  ConsumerState<SleepDiaryView> createState() => _SleepDiaryViewState();
}

class _SleepDiaryViewState extends ConsumerState<SleepDiaryView> {
  // 폼 상태 관리
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditMode = false;
  bool _isFormValid = false;
  bool _isFormChanged = false;
  bool _isWakeMethodOtherSelected = false;

  void toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  // 폼 변경 시 상태 업데이트
  void _onFormChanged() {
    final fs = _formKey.currentState;
    setState(() {
      _isFormValid = fs?.isValid ?? false;
      // compare current vs initial values for change detection
      _isFormChanged =
          fs?.fields.values.any((field) {
            final current = field.value;
            final initial = field.initialValue;
            return current != initial;
          }) ??
          false;
      _isWakeMethodOtherSelected =
          fs?.fields['wakeMethod']?.value == WakeMethod.other;
    });
  }

  @override
  Widget build(BuildContext context) {
    final diaryAsync = ref.watch(sleepDiaryByIdProvider(widget.reportId));

    return diaryAsync.when(
      data: (diary) {
        // 작성 전
        if (!_isEditMode &&
            (diary.sleepQuality == null ||
                diary.moodScore == null ||
                diary.wakeAwareness == null ||
                diary.wakeMethod == null)) {
          // 작성 전 화면
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
                // NOTE: 당일 수면인 경우에만 작성하기 버튼이 보여짐
                if (!_isEditMode && DateTime.parse(diary.sleepDate).isToday)
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
        }
        // 읽기 모드
        if (!_isEditMode) {
          return _buildDiaryForm(
            diary,
            ref: ref,
            reportId: widget.reportId,
            formKey: _formKey,
            readOnly: true,
            toggleEditMode: toggleEditMode,
            onChanged: _onFormChanged,
            isSavable: false,
          );
        }
        // 편집 모드
        return _buildDiaryForm(
          diary,
          ref: ref,
          reportId: widget.reportId,
          formKey: _formKey,
          readOnly: false,
          toggleEditMode: toggleEditMode,
          onChanged: _onFormChanged,
          isSavable:
              _isFormValid &&
              _isFormChanged &&
              (!_isWakeMethodOtherSelected ||
                  (_formKey.currentState?.fields['wakeMethodEtc']?.value !=
                      null)),
        );
      },
      loading:
          () => Expanded(
            child: Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: AppColors.font2,
                ),
              ),
            ),
          ),
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
  final Future<void> Function()? onTap;

  const _SummaryHeader({required this.title, required this.isEdit, this.onTap});

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
              onTap:
                  onTap ??
                  () {
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

// 이전 날짜를 'M월 D일'로 반환하는 함수
String _getPreviousDay(String date) {
  final dt = DateTime.parse(date);
  final prev = dt.subtract(Duration(days: 1));
  return '${prev.month}월 ${prev.day}일';
}

Widget _buildDiaryForm(
  SleepDiaryModel diary, {
  required WidgetRef ref,
  required int reportId,
  required GlobalKey<FormBuilderState> formKey,
  required bool readOnly,
  required VoidCallback toggleEditMode,
  required VoidCallback onChanged,
  required bool isSavable,
}) {
  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final min = int.parse(parts[1]);
    final period = hour >= 12 ? '오후' : '오전';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$period $displayHour:${min.toString().padLeft(2, '0')}';
  }

  return FormBuilder(
    key: formKey,
    onChanged: onChanged,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Builder(
      builder:
          (formContext) => Column(
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
                                      '${_getPreviousDay(diary.sleepDate)}에는 총  ',
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Text(
                                    _calculateSleepDurationInMinutes(
                                      FormBuilder.of(
                                                formContext,
                                              )?.fields['sleepTime']?.value
                                              as String? ??
                                          diary.sleepTime,
                                      FormBuilder.of(
                                                formContext,
                                              )?.fields['wakeTime']?.value
                                              as String? ??
                                          diary.wakeTime,
                                    ),
                                    style: AppTextStyles.titleT1Sb(
                                      color: AppColors.sub1,
                                    ),
                                  ),
                                ),
                                const TextSpan(text: '  동안 잤습니다.'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // NOTE: readOnly이고 지금 보고 있는 수면일지가 오늘의 수면일지라면 편집 버튼을 보여줌
                      if (readOnly && DateTime.parse(diary.sleepDate).isToday)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 4,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: toggleEditMode,
                              child: Text(
                                '수정하기',
                                style: AppTextStyles.button3Md(
                                  color: AppColors.sub1,
                                ),
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
                                          isEdit: !readOnly,
                                          onTap: () async {
                                            final parts =
                                                FormBuilder.of(formContext)
                                                    ?.fields['sleepTime']
                                                    ?.value
                                                    ?.split(':') ??
                                                ['0', '0'];
                                            final ih =
                                                int.tryParse(parts[0]) ?? 0;
                                            final im =
                                                int.tryParse(parts[1]) ?? 0;
                                            final t =
                                                await showCustomTimePicker(
                                                  context: formContext,
                                                  initialHour: ih,
                                                  initialMinute: im,
                                                  showPeriodPicker: true,
                                                  formType:
                                                      CustomTimePickerForm
                                                          .sleepStart,
                                                );

                                            if (t != null) {
                                              final formatted =
                                                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                                              FormBuilder.of(formContext)
                                                  ?.fields['sleepTime']
                                                  ?.didChange(formatted);
                                            }
                                          },
                                        ),
                                        FormBuilderField<String>(
                                          name: 'sleepTime',
                                          initialValue:
                                              diary.sleepTime, // “07:05” 그대로 저장
                                          builder: (field) {
                                            // 화면엔 포맷된 값만 보여줌
                                            return Text(
                                              _formatTime(field.value!),
                                              style: AppTextStyles.titleT3Sb(
                                                color: AppColors.white,
                                              ),
                                            );
                                          },
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
                                          isEdit: !readOnly,
                                          onTap: () async {
                                            final parts =
                                                FormBuilder.of(formContext)
                                                    ?.fields['wakeTime']
                                                    ?.value
                                                    ?.split(':') ??
                                                ['0', '0'];
                                            final ih =
                                                int.tryParse(parts[0]) ?? 0;
                                            final im =
                                                int.tryParse(parts[1]) ?? 0;
                                            final t =
                                                await showCustomTimePicker(
                                                  context: formContext,
                                                  initialHour: ih,
                                                  initialMinute: im,
                                                  showPeriodPicker: true,
                                                  formType:
                                                      CustomTimePickerForm
                                                          .wakeUp,
                                                );

                                            if (t != null) {
                                              final formatted =
                                                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                                              FormBuilder.of(formContext)
                                                  ?.fields['wakeTime']
                                                  ?.didChange(formatted);
                                            }
                                          },
                                        ),
                                        FormBuilderField<String>(
                                          name: 'wakeTime',
                                          initialValue:
                                              diary.wakeTime, // “07:05” 그대로 저장
                                          builder: (field) {
                                            // 화면엔 포맷된 값만 보여줌
                                            return Text(
                                              _formatTime(field.value!),
                                              style: AppTextStyles.titleT3Sb(
                                                color: AppColors.white,
                                              ),
                                            );
                                          },
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
                                          isEdit: !readOnly,
                                          onTap: () async {
                                            final count =
                                                await showWakeCountModal(
                                                  context: formContext,
                                                  initialCount:
                                                      diary.wakeCount!,
                                                );

                                            if (count != null) {
                                              FormBuilder.of(formContext)
                                                  ?.fields['wakeCount']
                                                  ?.didChange(count);
                                            }
                                          },
                                        ),
                                        FormBuilderField<int>(
                                          name: 'wakeCount',
                                          initialValue:
                                              diary.wakeCount!, // 숫자 그대로 저장
                                          builder: (field) {
                                            // 화면엔 포맷된 값만 보여줌
                                            return Text(
                                              "${field.value!} 회",
                                              style: AppTextStyles.titleT3Sb(
                                                color: AppColors.white,
                                              ),
                                            );
                                          },
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
                                          '${diary.sleepLatency} 분',
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
                              enabled: !readOnly,
                              direction: Axis.vertical,
                              name: 'sleepQuality',
                              initialValue: diary.sleepQuality,
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
                              validator: FormBuilderValidators.required(
                                errorText: '수면의 질을 선택해주세요.',
                              ),
                            ),
                            SizedBox(height: 12),
                            _QuestionHeader(title: '기상 후 기분은 어떠신가요? '),
                            CustomRadioGroup(
                              enabled: !readOnly,
                              direction: Axis.vertical,
                              name: 'moodScore',
                              initialValue: diary.moodScore,
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
                              validator: FormBuilderValidators.required(
                                errorText: '기상 후 기분을 선택해주세요.',
                              ),
                            ),
                            SizedBox(height: 12),
                            _QuestionHeader(title: '잠은 다 깨셨나요?'),
                            CustomRadioGroup(
                              enabled: !readOnly,
                              direction: Axis.vertical,
                              name: 'wakeAwareness',
                              initialValue: diary.wakeAwareness,
                              options: [
                                WakeAwareness.no,
                                WakeAwareness.normal,
                                WakeAwareness.yes,
                              ],
                              labels: ['아니오', '보통', '네'],
                              validator: FormBuilderValidators.required(
                                errorText: '잠은 다 깼는지를 선택해주세요.',
                              ),
                            ),
                            SizedBox(height: 12),
                            _QuestionHeader(title: '어떻게 일어나셨나요?'),
                            CustomRadioGroup(
                              enabled: !readOnly,
                              direction: Axis.vertical,
                              name: 'wakeMethod',
                              initialValue: diary.wakeMethod,
                              options: [
                                WakeMethod.alarm,
                                WakeMethod.byPerson,
                                WakeMethod.self,
                                WakeMethod.noise,
                                WakeMethod.other,
                              ],
                              labels: ['알람', '누군가 깨움', '스스로 일어남', '소음', '기타'],
                              validator: FormBuilderValidators.required(
                                errorText: '어떻게 일어났는지 선택해주세요.',
                              ),
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
                                        initialValue: diary.wakeMethodEtc,
                                        validator:
                                            FormBuilderValidators.required(
                                              errorText: '기타 항목을 작성해주세요.',
                                            ),
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
              // 푸터 버튼. readOnly가 false일 때만 보여짐
              // NOTE: 작성상태인 경우에만 보여야 함.
              if (!readOnly)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12,
                  ),
                  child: CustomButton(
                    disabled: !isSavable,
                    onPressed: () {
                      if (formKey.currentState?.saveAndValidate() ?? false) {
                        final values = formKey.currentState!.value;
                        final req = UpdateSleepDiaryRequest(
                          sleepReportId: diary.sleepReportId,
                          sleepDate: values['sleepDate'] as String?,
                          sleepTime: values['sleepTime'] as String?,
                          wakeTime: values['wakeTime'] as String?,
                          sleepLatency: values['sleepLatency'] as String?,
                          wakeCount: values['wakeCount'] as int?,
                          sleepQuality: values['sleepQuality'] as int?,
                          moodScore: values['moodScore'] as int?,
                          wakeAwareness:
                              values['wakeAwareness'] as WakeAwareness?,
                          wakeMethod: values['wakeMethod'] as WakeMethod?,
                          wakeMethodEtc:
                              values['wakeMethod'] == WakeMethod.other
                                  ? values['wakeMethodEtc'] as String?
                                  : null,
                        );
                        ref.read(sleepDiaryProvider).updateSleepDiary(req).then(
                          (_) {
                            ref.invalidate(sleepDiaryByIdProvider(reportId));
                            // 수면코칭 요청 post api 추가
                            // TODO: 최초 생성시에만 하는건지 알아보기
                            ref
                                .read(sleepCoachRepositoryProvider)
                                .createSleepCoach(
                                  CreateSleepCoachingRequest(
                                    sleepReportId: reportId,
                                  ),
                                );

                            toggleEditMode();
                          },
                        );
                      }
                    },
                    height: 48,
                    text: '작성 완료',
                    theme: 'gray',
                  ),
                ),
            ],
          ),
    ),
  );
}
