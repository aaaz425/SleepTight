import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/config/router.dart';
import 'core/config/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Todo: 로컬라이제이션 추가
  await initializeDateFormatting('ko_KR', null);
  runApp(const ProviderScope(child: SleepTightApp()));
}

class SleepTightApp extends StatelessWidget {
  const SleepTightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sleep Tight',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
    );
  }
}
