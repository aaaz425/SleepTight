import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/user/presentation/screens/user_screen.dart';

void main() {
  testWidgets('User name changes on button press', (WidgetTester tester) async {
    // 위젯을 ProviderScope로 감싸서 테스트 환경 구성
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: UserScreen())),
    );

    // 초기 상태: "Guest"라는 텍스트가 보여야 함
    expect(find.text('Hello, Guest'), findsOneWidget);
    expect(find.text('Hello, 홍길동'), findsNothing);

    // 버튼을 눌러 상태 변경
    await tester.tap(find.text('이름 변경'));
    await tester.pump();

    // 이름이 '홍길동'으로 변경되었는지 확인
    expect(find.text('Hello, Guest'), findsNothing);
    expect(find.text('Hello, 홍길동'), findsOneWidget);
  });
}
