import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_birth_date_request.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:sleep_tight/features/user/presentation/widgets/birth_date_form_field.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_header.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';

// 폼 유효성 상태를 위한 StateProvider
final myPageInfoBirthDateFormValidProvider = StateProvider<bool>(
  (ref) => false,
);
// 폼 내용 변경 여부 상태를 위한 StateProvider
final myPageInfoBirthDateFormHasChangedProvider = StateProvider<bool>(
  (ref) => false,
);

class MyPageInfoBirthDateScreen extends ConsumerWidget {
  MyPageInfoBirthDateScreen({super.key});

  final _formKey = GlobalKey<FormBuilderState>();

  static const String yearFieldName = 'year';
  static const String monthFieldName = 'month';
  static const String dayFieldName = 'day';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider);
    final isFormValid = ref.watch(myPageInfoBirthDateFormValidProvider);
    final formHasChanged = ref.watch(myPageInfoBirthDateFormHasChangedProvider);

    String initialYear = '';
    String initialMonth = '';
    String initialDay = '';

    final userBirthDateStr = user?.birthDate; // "yyyy-mm-dd" 형식의 문자열 또는 null
    if (userBirthDateStr != null && userBirthDateStr.isNotEmpty) {
      final parts = userBirthDateStr.split('-');
      if (parts.length == 3) {
        initialYear = parts[0];
        // "08" -> 8 -> "8" 로 변환 (앞의 0 제거)
        initialMonth = int.tryParse(parts[1])?.toString() ?? parts[1];
        initialDay =
            int.tryParse(parts[2])?.toString() ??
            parts[2]; // 일(day)도 마찬가지로 처리 가능
      } else {
        // 잘못된 형식의 날짜 문자열 처리 (예: 로그 남기기)
        debugPrint(
          'Warning: User birthDate string is not in yyyy-mm-dd format: $userBirthDateStr',
        );
      }
    }

    final initialFormValues = {
      yearFieldName: initialYear,
      monthFieldName: initialMonth,
      dayFieldName: initialDay,
    };

    return SafeArea(
      child: Scaffold(
        appBar: MyPageAppBar(
          onBack: () {
            if (context.canPop()) {
              context.pop();
              ref.invalidate(myPageInfoBirthDateFormHasChangedProvider);
              ref.invalidate(myPageInfoBirthDateFormValidProvider);
            }
          },
        ),
        body: FormBuilder(
          key: _formKey,
          initialValue: initialFormValues,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            final form = _formKey.currentState;
            if (form != null) {
              form.save();
              final currentValues = form.value;
              final initialValuesFromForm = form.initialValue;

              final isValid = form.validate();
              ref.read(myPageInfoBirthDateFormValidProvider.notifier).state =
                  isValid;

              bool changed =
                  !const DeepCollectionEquality().equals(
                    currentValues,
                    initialValuesFromForm,
                  );
              ref
                  .read(myPageInfoBirthDateFormHasChangedProvider.notifier)
                  .state = changed;
            } else {
              ref.read(myPageInfoBirthDateFormValidProvider.notifier).state =
                  false;
              ref
                  .read(myPageInfoBirthDateFormHasChangedProvider.notifier)
                  .state = false;
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                MyPageHeader(title: '생년월일을 입력해주세요'), // 헤더 타이틀 수정
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BirthDateFormField(), // 년, 월, 일 필드를 포함
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: CustomButton(
              onPressed: () async {
                final form = _formKey.currentState;
                if (form == null) return;

                if (form.saveAndValidate()) {
                  final values = form.value;
                  final String yearStr =
                      values[yearFieldName]?.toString() ?? '';
                  final String monthStr =
                      values[monthFieldName]?.toString() ?? '';
                  final String dayStr = values[dayFieldName]?.toString() ?? '';

                  // 월과 일이 한 자리 수일 경우 앞에 '0'을 붙여 두 자리로 만듭니다.
                  final String formattedMonth = monthStr.padLeft(2, '0');
                  final String formattedDay = dayStr.padLeft(2, '0');

                  // 년, 월, 일이 비어있는지 또는 유효한지 기본적인 클라이언트 측 검증
                  if (yearStr.isEmpty || monthStr.isEmpty || dayStr.isEmpty) {
                    debugPrint('Year, month, or day is empty.');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('년, 월, 일을 모두 입력해주세요.')),
                      );
                    }
                    return;
                  }

                  // "yyyy-MM-dd" 형식으로 생년월일 문자열 생성
                  final String newBirthDate =
                      "$yearStr-$formattedMonth-$formattedDay";

                  // 생성된 날짜 문자열이 유효한 날짜인지 확인 (선택적이지만 권장)
                  if (DateTime.tryParse(newBirthDate) == null) {
                    debugPrint(
                      'Constructed birth date is invalid: $newBirthDate',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('유효하지 않은 날짜 형식입니다.')),
                      );
                    }
                    return;
                  }

                  final request = UpdateUserBirthDateRequest(
                    birthDate: newBirthDate,
                  );

                  try {
                    await ref
                        .read(userModelProvider.notifier)
                        .updateBirthDate(request);

                    ref.invalidate(myPageInfoBirthDateFormHasChangedProvider);
                    ref.invalidate(myPageInfoBirthDateFormValidProvider);

                    if (context.mounted && context.canPop()) {
                      context.pop();
                    }
                  } catch (e) {
                    debugPrint('생년월일 변경 실패: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('생년월일 변경 중 오류가 발생했습니다: $e')),
                      );
                    }
                  }
                } else {
                  debugPrint('입력값을 확인해주세요. (onPressed 최종 검사)');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('입력값을 확인해주세요.')),
                    );
                  }
                }
              },
              height: 48,
              text: '완료',
              theme: 'gray',
              disabled: !(isFormValid && formHasChanged),
            ),
          ),
        ),
      ),
    );
  }
}
