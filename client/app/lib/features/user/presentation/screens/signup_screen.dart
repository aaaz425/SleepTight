import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/user/data/models/enums/country.dart';
import 'package:sleep_tight/features/user/data/models/enums/gender.dart';
import 'package:sleep_tight/features/user/data/models/enums/length_unit.dart';
import 'package:sleep_tight/features/user/data/models/enums/weight_unit.dart';
import 'package:sleep_tight/features/user/data/models/requests/user_register_request.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:sleep_tight/shared/widgets/custom_text_field.dart';
import 'package:sleep_tight/shared/widgets/custom_dropdown.dart';
import 'package:sleep_tight/shared/widgets/custom_radio_group.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: SignupScreenBody()));
  }
}

// Riverpod ConsumerWidget 사용
class SignupScreenBody extends ConsumerWidget {
  SignupScreenBody({super.key});

  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm(WidgetRef ref) async {
    final formState = _formKey.currentState;
    if (formState?.saveAndValidate() ?? false) {
      // gender와 birth_date 포맷팅
      final raw = formState!.value;
      final genderJson = (raw['gender'] as Gender).toJson;
      final year = raw['year'] as String;
      final month = raw['month'] as String;
      final day = raw['day'] as String;
      final birthDate =
          '${year.padLeft(4, '0')}-${month.padLeft(2, '0')}-${day.padLeft(2, '0')}';
      final countryEn = Country.findByKoreanName(raw['country'] as String);
      // height와 weight 문자열을 숫자로 변환
      final heightVal = double.tryParse(raw['height'] as String) ?? 0;
      final weightVal = double.tryParse(raw['weight'] as String) ?? 0;
      final formattedData =
          Map<String, dynamic>.from(raw)
            ..remove('year')
            ..remove('month')
            ..remove('day')
            ..remove('country')
            ..remove('height')
            ..remove('weight')
            ..addAll({
              'gender': genderJson,
              'birth_date': birthDate,
              'country': countryEn,
              'height': heightVal,
              'weight': weightVal,
            });

      // API로 가입 요청 전송
      final request = UserRegisterRequest.fromJson(formattedData);
      await ref.read(userModelProvider.notifier).registerUser(request);
    } else {
      debugPrint('폼 유효성 검사 실패');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const _SignupHeader(),
        Expanded(child: _SignupFormBody(formKey: _formKey)),
        _SignupFooter(onNext: () => _submitForm(ref)),
      ],
    );
  }
}

// 헤더: 뒤로가기 버튼 + "회원가입" 타이틀
class _SignupHeader extends StatelessWidget {
  const _SignupHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: [
          IconButton(
            icon: SvgPicture.asset('assets/icons/arrow_left.svg'),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          const Text(
            '회원가입',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600, // semibold
              fontSize: 28,
              height: 1.4, // 140%
              letterSpacing: -0.7, // -2.5% of 28 = -0.7
              color: Colors.white,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// 바디: 입력 폼(이름, 성별, 생년월일, 국적, 키, 몸무게 등)
class _SignupFormBody extends ConsumerStatefulWidget {
  final GlobalKey<FormBuilderState> formKey;
  const _SignupFormBody({required this.formKey});

  @override
  ConsumerState<_SignupFormBody> createState() => _SignupFormBodyState();
}

class _SignupFormBodyState extends ConsumerState<_SignupFormBody> {
  // IP 기반 초기 국적 조회
  late Future<Country?> _initialCountry;

  @override
  void initState() {
    super.initState();
    _initialCountry = _fetchCountryName();
  }

  Future<Country?> _fetchCountryName() async {
    try {
      final apiKey = dotenv.env['IP2LOCATION_API_KEY'];
      if (apiKey == null) {
        debugPrint('IP2LOCATION_API_KEY가 .env에 없습니다.');
        return null;
      }
      // 실제 사용시 ip 파라미터를 동적으로 할당하거나 생략 가능 (현재는 예시로 고정 IP)
      final url = 'https://api.ip2location.io/?key=$apiKey';
      final res = await ref.read(dioClientProvider).dio.get(url);
      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;
        final code = data['country_code'] as String?;
        return code != null ? Country.findByCountryCode(code) : null;
      }
    } catch (e) {
      debugPrint('IP 위치 조회 실패: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUnfocus,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // 이름 입력
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '이름',
                style: AppTextStyles.titleT3Sb(color: Colors.white),
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    name: 'last_name',
                    label: '성',
                    hintText: '성을 입력해주세요.',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: '성을 입력하세요.'),
                      FormBuilderValidators.maxLength(
                        20,
                        errorText: '20자 이하로 입력하세요.',
                      ),
                    ]),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: CustomTextField(
                    name: 'first_name',
                    label: '이름',
                    hintText: '이름을 입력해주세요.',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: '이름을 입력하세요.'),
                      FormBuilderValidators.maxLength(
                        20,
                        errorText: '20자 이하로 입력하세요.',
                      ),
                    ]),
                  ),
                ),
              ],
            ),

            // 성별
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '성별',
                style: AppTextStyles.titleT3Sb(color: Colors.white),
              ),
            ),
            SizedBox(height: 12),

            CustomRadioGroup<Gender>(
              name: 'gender',
              initialValue: Gender.male,
              options: Gender.values,
              labels: Gender.values.map((gender) => gender.ko).toList(),
              selectedColor: AppColors.primary,
              unselectedColor: Colors.transparent,
              borderColor: AppColors.gray06,
              validator: FormBuilderValidators.required(
                errorText: '성별을 선택하세요.',
              ),
              direction: Axis.horizontal,
            ),

            SizedBox(height: 20),

            // 생년월일
            // custom_dropdown이 3개가 가로로 배치되어야 함
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '생년월일',
                style: AppTextStyles.titleT3Sb(color: Colors.white),
              ),
            ),
            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CustomDropdown(
                    name: 'year',
                    initialValue: null,
                    hintText: 'YYYY',
                    validator: FormBuilderValidators.required(
                      errorText: '년도를 선택하세요.',
                    ),
                    values: List.generate(
                      100,
                      (index) => (2025 - 100 + index).toString(),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: CustomDropdown(
                    name: 'month',
                    initialValue: null,
                    hintText: 'MM',
                    validator: FormBuilderValidators.required(
                      errorText: '월을 선택하세요.',
                    ),
                    values: List.generate(
                      12,
                      (index) => (index + 1).toString(),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: CustomDropdown(
                    name: 'day',
                    initialValue: null,
                    hintText: 'DD',
                    validator: FormBuilderValidators.required(
                      errorText: '일을 선택하세요.',
                    ),
                    values: List.generate(
                      31,
                      (index) => (index + 1).toString(),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // 국적
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '국적',
                style: AppTextStyles.titleT3Sb(color: Colors.white),
              ),
            ),
            SizedBox(height: 12),
            FutureBuilder<Country?>(
              future: _initialCountry,
              builder: (context, snapshot) {
                final countryByIp =
                    snapshot.connectionState == ConnectionState.done
                        ? snapshot.data
                        : null;
                debugPrint(countryByIp?.getDisplayName('ko') ?? '');
                return CustomDropdown(
                  key: ValueKey(countryByIp?.getDisplayName('ko') ?? ''),
                  name: 'country',
                  initialValue: countryByIp?.getDisplayName('ko'),
                  hintText: '선택',
                  validator: FormBuilderValidators.required(
                    errorText: '국적을 선택하세요.',
                  ),
                  values:
                      Country.values
                          .map((c) => c.getDisplayName('ko'))
                          .toList(),
                );
              },
            ),

            SizedBox(height: 20),

            // 키 입력
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '키',
                style: AppTextStyles.titleT3Sb(color: Colors.white),
              ),
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    name: 'height',

                    hintText: '키를 입력해주세요.',
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: '키를 입력하세요.'),
                      FormBuilderValidators.numeric(errorText: '숫자만 입력하세요.'),
                      // length_unit에 따라서 validation 다르게 적용
                      // cm면 100이상 300 이하
                      // ft/in면 3이상 10 이하
                      (value) {
                        final unit =
                            widget
                                .formKey
                                .currentState
                                ?.fields['length_unit']
                                ?.value;
                        if (value == null || value.isEmpty) return null;
                        final num? height = num.tryParse(value);
                        if (height == null) return null;

                        if (unit == 'cm') {
                          if (height < 100 || height > 300) {
                            return '키(cm)는 100~300 사이여야 합니다.';
                          }
                        } else if (unit == 'ft/in') {
                          if (height < 3 || height > 10) {
                            return '키(ft/in)는 3~10 사이여야 합니다.';
                          }
                        }
                        return null;
                      },
                    ]),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CustomDropdown(
                      name: 'length_unit',
                      initialValue: LengthUnit.cm.value,
                      values: LengthUnit.values.map((u) => u.value).toList(),
                      validator: FormBuilderValidators.required(
                        errorText: '길이 단위를 선택하세요.',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 몸무게 입력
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '몸무게',
                style: AppTextStyles.titleT3Sb(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    name: 'weight',
                    hintText: '몸무게를 입력해주세요.',
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: '몸무게를 입력하세요.'),
                      FormBuilderValidators.numeric(errorText: '숫자만 입력하세요.'),
                      (value) {
                        final unit =
                            widget
                                .formKey
                                .currentState
                                ?.fields['weight_unit']
                                ?.value;
                        if (value == null || value.isEmpty) return null;
                        final num? weight = num.tryParse(value);
                        if (weight == null) return null;
                        if (unit == 'kg') {
                          if (weight < 20 || weight > 300) {
                            return '몸무게(kg)는 20~300 사이여야 합니다.';
                          }
                        } else if (unit == 'lb') {
                          if (weight < 44 || weight > 660) {
                            return '몸무게(lb)는 44~660 사이여야 합니다.';
                          }
                        }
                        return null;
                      },
                    ]),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CustomDropdown(
                      name: 'weight_unit',
                      initialValue: WeightUnit.kg.value,
                      values: WeightUnit.values.map((u) => u.value).toList(),
                      validator: FormBuilderValidators.required(
                        errorText: '몸무게 단위를 선택하세요.',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 푸터: "다음" 버튼
class _SignupFooter extends StatelessWidget {
  final VoidCallback onNext;
  const _SignupFooter({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 32, left: 20, right: 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: onNext,
          child: Text(
            '다음',
            style: AppTextStyles.button1Sb(color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
