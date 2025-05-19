import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:collection/collection.dart'; // isDirty 사용 시 필요 없음
import 'package:sleep_tight/features/user/data/models/enums/country.dart'; // Country enum/class import
import 'package:sleep_tight/features/user/data/models/requests/update_user_country_request.dart';
// import 'package:sleep_tight/features/user/data/models/requests/update_user_nationality_request.dart'; // 사용되지 않음
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:sleep_tight/features/user/presentation/widgets/country_form_field.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_header.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';

// 폼 유효성 상태를 위한 StateProvider
final myPageInfoNationalityFormValidProvider = StateProvider<bool>(
  // 초기값은 필드의 validator와 초기 상태에 따라 달라질 수 있음
  // CountryFormField가 required이고 초기값이 없으면 false가 적절
  (ref) => false,
);
// 폼 내용 변경 여부 상태를 위한 StateProvider
final myPageInfoNationalityFormHasChangedProvider = StateProvider<bool>(
  (ref) => false,
);

class MyPageInfoNationalityScreen extends ConsumerWidget {
  MyPageInfoNationalityScreen({super.key});

  final _formKey = GlobalKey<FormBuilderState>();
  static const String countryFieldName = 'country';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider);
    final isFormValid = ref.watch(myPageInfoNationalityFormValidProvider);
    final formHasChanged = ref.watch(
      myPageInfoNationalityFormHasChangedProvider,
    );

    // userModelProvider에서 Country 객체를 직접 가져온다고 가정
    final Country initialCountry = Country.fromJson(user?.country ?? '');

    return SafeArea(
      child: Scaffold(
        appBar: MyPageAppBar(
          onBack: () {
            if (context.canPop()) {
              // 화면 나가기 전 상태 초기화
              ref.invalidate(myPageInfoNationalityFormHasChangedProvider);
              ref.invalidate(
                myPageInfoNationalityFormValidProvider,
              ); // 유효성 상태도 초기화
              context.pop();
            }
          },
        ),
        body: FormBuilder(
          key: _formKey,
          initialValue: {countryFieldName: initialCountry},
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final form = _formKey.currentState;
              if (form == null) {
                return;
              }

              form.save(); // 값 저장
              final isValid = form.validate(); // 유효성 검증

              final currentValidStateInProvider = ref.read(
                myPageInfoNationalityFormValidProvider,
              );
              if (isValid != currentValidStateInProvider) {
                ref
                    .read(myPageInfoNationalityFormValidProvider.notifier)
                    .state = isValid;
              }

              // 변경 여부 확인 (isDirty 플래그 사용)
              final fieldState = form.fields[countryFieldName];
              bool changed = fieldState?.isDirty ?? false;

              final currentChangedStateInProvider = ref.read(
                myPageInfoNationalityFormHasChangedProvider,
              );
              if (changed != currentChangedStateInProvider) {
                ref
                    .read(myPageInfoNationalityFormHasChangedProvider.notifier)
                    .state = changed;
              }

              debugPrint(
                'Nationality Form Changed: $changed (isDirty: ${fieldState?.isDirty}), Valid: $isValid',
              );
              debugPrint(
                'Field Initial: ${fieldState?.initialValue}, Field Value: ${fieldState?.value}',
              );
            });
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                MyPageHeader(title: '국적을 선택해주세요'),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CountryFormField(initialValue: initialCountry),
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

                // 최종 제출 전 한 번 더 유효성 검사 및 값 저장
                if (form.saveAndValidate()) {
                  // CountryFormField가 Country 객체를 반환한다고 가정
                  final String? selectedCountry =
                      form.value[countryFieldName] as String?;

                  if (selectedCountry == null) {
                    // CountryFormField의 validator가 이를 처리해야 하지만, 추가 방어 코드
                    debugPrint('Country not selected.');
                    final currentContext = _formKey.currentContext;
                    if (currentContext != null && currentContext.mounted) {
                      ScaffoldMessenger.of(currentContext).showSnackBar(
                        const SnackBar(content: Text('국적을 선택해주세요.')),
                      );
                    }
                    return;
                  }

                  final request = UpdateUserCountryRequest(
                    country: Country.findByKoreanName(selectedCountry)!,
                  );

                  try {
                    await ref
                        .read(userModelProvider.notifier)
                        .updateCountry(request);

                    final currentContext = _formKey.currentContext;
                    if (currentContext != null &&
                        currentContext.mounted &&
                        GoRouter.of(currentContext).canPop()) {
                      // 성공 후 상태 초기화 및 화면 닫기
                      ref.invalidate(
                        myPageInfoNationalityFormHasChangedProvider,
                      );
                      ref.invalidate(myPageInfoNationalityFormValidProvider);
                      GoRouter.of(currentContext).pop();
                    }
                  } catch (e) {
                    debugPrint('국적 변경 실패: $e'); // 오류 메시지 수정
                    final currentContext = _formKey.currentContext;
                    if (currentContext != null && currentContext.mounted) {
                      ScaffoldMessenger.of(currentContext).showSnackBar(
                        SnackBar(content: Text('국적 변경 중 오류가 발생했습니다: $e')),
                      );
                    }
                  }
                } else {
                  debugPrint('입력값을 확인해주세요. (onPressed 최종 검사)');
                  final currentContext = _formKey.currentContext;
                  if (currentContext != null && currentContext.mounted) {
                    ScaffoldMessenger.of(currentContext).showSnackBar(
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
