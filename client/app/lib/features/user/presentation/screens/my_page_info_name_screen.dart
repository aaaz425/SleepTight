import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart'; // DeepCollectionEquality를 위해 추가
import 'package:sleep_tight/features/user/data/models/requests/update_user_name_request.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_header.dart';
import 'package:sleep_tight/features/user/presentation/widgets/name_form_field.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';

// 폼 유효성 상태를 위한 StateProvider
final myPageInfoNameFormValidProvider = StateProvider<bool>((ref) => false);
// 폼 내용 변경 여부 상태를 위한 StateProvider
final myPageInfoNameFormHasChangedProvider = StateProvider<bool>(
  (ref) => false,
);

class MyPageInfoNameScreen extends ConsumerWidget {
  MyPageInfoNameScreen({super.key});

  final _formKey = GlobalKey<FormBuilderState>();

  // NameFormField 내부의 FormBuilderTextField 이름들 (실제 사용하는 이름으로 변경 필요)
  static const String firstNameFieldName = 'first_name';
  static const String lastNameFieldName = 'last_name';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider);
    final isFormValid = ref.watch(myPageInfoNameFormValidProvider);
    final formHasChanged = ref.watch(myPageInfoNameFormHasChangedProvider);

    // FormBuilder에 전달할 초기값 맵 구성
    final initialFormValues = {
      firstNameFieldName: user?.firstName ?? '',
      lastNameFieldName: user?.lastName ?? '',
    };

    return SafeArea(
      child: Scaffold(
        appBar: MyPageAppBar(
          onBack: () {
            if (context.canPop()) {
              context.pop();
              ref.invalidate(myPageInfoNameFormHasChangedProvider);
              ref.invalidate(myPageInfoNameFormValidProvider);
            }
          },
        ),
        body: FormBuilder(
          key: _formKey,
          initialValue: initialFormValues, // 폼 빌더에 초기값 설정
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            final form = _formKey.currentState;
            if (form != null) {
              form.save(); // 현재 값들을 폼 상태에 저장
              final currentValues = form.value; // 현재 폼 값들
              // initialValue는 FormBuilder에 설정된 초기값 그대로 유지됨
              final initialValuesFromForm = form.initialValue;

              // 1. 유효성 상태 업데이트
              final isValid = form.validate();
              ref.read(myPageInfoNameFormValidProvider.notifier).state =
                  isValid;

              // 2. 변경 여부 상태 업데이트
              // DeepCollectionEquality().equals()를 사용하여 맵의 내용을 깊은 비교
              bool changed =
                  !const DeepCollectionEquality().equals(
                    currentValues,
                    initialValuesFromForm,
                  );
              ref.read(myPageInfoNameFormHasChangedProvider.notifier).state =
                  changed;
            } else {
              ref.read(myPageInfoNameFormValidProvider.notifier).state = false;
              ref.read(myPageInfoNameFormHasChangedProvider.notifier).state =
                  false;
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                MyPageHeader(title: '이름을 입력해주세요'),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: NameFormField(
                    // FormBuilder의 initialValue를 사용하므로,
                    // NameFormField에 직접 firstName, lastName을 전달할 필요가 없을 수 있습니다.
                    // 단, NameFormField가 FormBuilder의 필드 이름(예: 'first_name', 'last_name')을
                    // 사용하여 값을 참조하도록 구현되어 있어야 합니다.
                    // 만약 NameFormField가 자체적으로 초기값을 관리한다면 이 부분은 그대로 두거나 조정 필요.
                  ),
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
                // 1. async 키워드 추가
                final form = _formKey.currentState;
                if (form == null) return;

                // 2. 폼 저장 및 최종 유효성 검사
                if (form.saveAndValidate()) {
                  final values = form.value;
                  // NameFormField 내부 필드 이름과 일치해야 함
                  final String newFirstName =
                      values[MyPageInfoNameScreen.firstNameFieldName] as String;
                  final String newLastName =
                      values[MyPageInfoNameScreen.lastNameFieldName] as String;

                  // 3. API 요청 객체 생성
                  final request = UpdateUserNameRequest(
                    firstName: newFirstName,
                    lastName: newLastName,
                  );

                  try {
                    // 4. API 호출하여 이름 업데이트
                    await ref
                        .read(userModelProvider.notifier)
                        .updateName(request);

                    ref.invalidate(myPageInfoNameFormHasChangedProvider);
                    ref.invalidate(myPageInfoNameFormValidProvider);

                    // 5. 성공 시 현재 화면 닫기 (이전 화면으로 이동)
                    if (context.mounted && context.canPop()) {
                      context.pop();
                    }
                  } catch (e) {
                    // 6. 오류 발생 시 로그 출력
                    debugPrint('이름 변경 실패: $e');
                    // 여기에 사용자에게 보여줄 간단한 오류 메시지 추가 가능 (예: SnackBar)
                    // if (context.mounted) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
                    //   );
                    // }
                  }
                } else {
                  // 최종 유효성 검사 실패 시 로그
                  debugPrint('입력값을 확인해주세요. (onPressed 최종 검사)');
                }
              },
              height: 48,
              text: '완료',
              theme: 'gray',
              disabled:
                  !(isFormValid && formHasChanged), // 유효하고 && 변경되었을 때만 활성화
            ),
          ),
        ),
      ),
    );
  }
}
