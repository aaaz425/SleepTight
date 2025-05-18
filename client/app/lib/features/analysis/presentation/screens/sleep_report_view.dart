import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/theme/color.dart';

class SleepReportView extends ConsumerStatefulWidget {
  const SleepReportView({super.key});

  @override
  ConsumerState<SleepReportView> createState() => _SleepReportViewState();
}

class _SleepReportViewState extends ConsumerState<SleepReportView> {
  @override
  void initState() {
    super.initState();
    // 예시: 데이터 패칭 시작
    Future.microtask(() {
      // ref.read(sleepReportProvider.notifier).fetch(); // 예시
    });
  }

  @override
  Widget build(BuildContext context) {
    // final report = ref.watch(sleepReportProvider);

    // return report.when(
    //   data: (data) => Center(child: Text('수면 리포트: ${data.title}')),
    //   loading: () => const Center(child: CircularProgressIndicator()),
    //   error: (err, stack) => Center(child: Text('오류: $err')),
    // );
    return SingleChildScrollView(
      child: Column(
        children: [
          // 수면 리포트 타이틀
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: AppColors.white, fontSize: 16),
                children: [
                  TextSpan(text: '4월 8일에는 총 '),
                  TextSpan(
                    text: '8시간 2분',
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

          // 시간 분석
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gray02,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '취침 시간',
                                style: TextStyle(
                                  color: AppColors.font2,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '오후 11:30',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '기상 시간',
                                style: TextStyle(
                                  color: AppColors.font2,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '오전 07:30',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '누워 있던 시간',
                              style: TextStyle(
                                color: AppColors.font2,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '8시간 32분',
                              style: TextStyle(
                                color: AppColors.sub1,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '실제 수면 시간',
                              style: TextStyle(
                                color: AppColors.font2,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '8시간 11분',
                              style: TextStyle(
                                color: AppColors.sub1,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '잠드는 데 걸린 시간',
                              style: TextStyle(
                                color: AppColors.font2,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '21분',
                              style: TextStyle(
                                color: AppColors.sub1,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '잠에서 깬 횟수',
                              style: TextStyle(
                                color: AppColors.font2,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '3회',
                              style: TextStyle(
                                color: AppColors.sub1,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 수면 단계
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '수면 단계',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  // Todo: 파형 그래프 수정
                  child: Image.asset(
                    'assets/images/sound_wave.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
          ),

          // 수면 단계
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text('수면 단계별 시간'),
                SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.gray02,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '누워 있던 시간',
                                  style: TextStyle(
                                    color: AppColors.font2,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '8시간 32분',
                                  style: TextStyle(
                                    color: AppColors.sub1,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '실제 수면 시간',
                                  style: TextStyle(
                                    color: AppColors.font2,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '8시간 11분',
                                  style: TextStyle(
                                    color: AppColors.sub1,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '잠드는 데 걸린 시간',
                                  style: TextStyle(
                                    color: AppColors.font2,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '21분',
                                  style: TextStyle(
                                    color: AppColors.sub1,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '잠에서 깬 횟수',
                                  style: TextStyle(
                                    color: AppColors.font2,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '3회',
                                  style: TextStyle(
                                    color: AppColors.sub1,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
