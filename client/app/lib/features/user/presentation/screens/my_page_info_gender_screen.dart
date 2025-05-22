import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// collection 패키지는 직접적인 필드 값 비교 시에는 필요 없을 수 있습니다.
// import 'package:collection/collection.dart';
import 'package:sleep_tight/features/user/data/models/enums/gender.dart';
import 'package:sleep_tight/features/user/data/models/requests/update_user_gender_request.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:sleep_tight/features/user/presentation/widgets/gender_form_field.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_header.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';

final myPageInfoGenderFormHasChangedProvider = StateProvider<bool>(
  (ref) => false,
);

class MyPageInfoGenderScreen extends ConsumerWidget {
  MyPageInfoGenderScreen({super.key});

  final _formKey = GlobalKey<FormBuilderState>();
  static const String genderFieldName = 'gender';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider);
    final formHasChanged = ref.watch(myPageInfoGenderFormHasChangedProvider);

    final Gender? initialGender = Gender.fromJson(user?.gender);

    return SafeArea(
      child: Scaffold(
        appBar: MyPageAppBar(
          onBack: () {
            if (context.canPop()) {
              context.pop();
              ref.invalidate(myPageInfoGenderFormHasChangedProvider);
            }
          },
        ),
        body: FormBuilder(
          key: _formKey,
          initialValue: {genderFieldName: initialGender},
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            // addPostFrameCallback을 사용하여 한 프레임 뒤에 실행
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final form = _formKey.currentState;
              // 위젯이 여전히 화면에 있는지 확인 (특히 비동기 작업 후)
              // ConsumerWidget에서는 this.mounted를 직접 사용할 수 없으므로,
              // form 키의 상태로 간접적으로 확인하거나, ConsumerStatefulWidget으로 변경 필요.
              // 여기서는 form != null로 체크합니다.
              if (form == null) {
                // form state가 없다면, 변경 상태를 false로 간주하거나 이전 상태 유지
                // ref.read(myPageInfoGenderFormHasChangedProvider.notifier).state = false;
                return;
              }

              // form.save(); // isDirty를 사용하면 명시적인 save 호출이 필요 없을 수 있음

              final fieldState = form.fields[genderFieldName];
              // FormBuilderField의 isDirty 플래그를 직접 사용
              bool changed = fieldState?.isDirty ?? false;

              debugPrint('--- FormBuilder onChanged (PostFrame) ---');
              debugPrint('Field isDirty: $changed');
              debugPrint('Current value: ${fieldState?.value}');
              debugPrint(
                'Field initial value (from state): ${fieldState?.initialValue}',
              );
              debugPrint('------------------------------------');

              // 현재 provider 상태와 새로운 changed 상태가 다를 때만 업데이트
              final currentChangedStateInProvider = ref.read(
                myPageInfoGenderFormHasChangedProvider,
              );
              if (changed != currentChangedStateInProvider) {
                ref
                    .read(myPageInfoGenderFormHasChangedProvider.notifier)
                    .state = changed;
              }
            });
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                MyPageHeader(title: '성별을 선택해주세요.'),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  // GenderFormField에 initialValue를 전달하여 FormBuilder의 값을 우선하도록 함
                  // GenderFormField 자체의 기본값은 FormBuilder에서 null이 올 때 사용됨
                  child: GenderFormField(initialValue: initialGender),
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
                  final Gender? selectedGender =
                      values[genderFieldName] as Gender?;

                  if (selectedGender == null) {
                    debugPrint('Gender not selected or invalid.');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('성별을 선택해주세요.')),
                      );
                    }
                    return;
                  }

                  final String apiGenderValue = selectedGender.toJson;
                  final request = UpdateUserGenderRequest(
                    gender: apiGenderValue,
                  );

                  try {
                    await ref
                        .read(userModelProvider.notifier)
                        .updateGender(request);
                    ref.invalidate(myPageInfoGenderFormHasChangedProvider);

                    if (context.mounted && context.canPop()) {
                      context.pop();
                    }
                  } catch (e) {
                    debugPrint('성별 변경 실패: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('성별 변경 중 오류가 발생했습니다: $e')),
                      );
                    }
                  }
                } else {
                  debugPrint('입력값을 확인해주세요. (onPressed 최종 검사)');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('선택값을 확인해주세요.')),
                    );
                  }
                }
              },
              height: 48,
              text: '완료',
              theme: 'gray',
              disabled: !formHasChanged,
            ),
          ),
        ),
      ),
    );
  }
}
