// 기본적인 스모크 테스트 — 앱이 정상적으로 켜지고 시작 화면이 뜨는지 확인

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surbi_web/main.dart';

void main() {
  testWidgets('Surbi 앱이 정상적으로 시작화면을 보여준다', (WidgetTester tester) async {
    // ProviderScope로 감싼 SurbiApp을 화면에 띄움
    await tester.pumpWidget(const ProviderScope(child: SurbiApp()));
    await tester.pumpAndSettle();

    // 시작 화면(router.dart의 '/' 경로)에 '분 시작' 텍스트가 보이는지 확인
    expect(find.text('Surbi 시작'), findsOneWidget);
  });
}
