// 메인 화면 스모크 테스트.
//
// tester.pumpWidget으로 앱을 한 프레임 그려보고,
// find.text / find.byIcon으로 화면에 뭐가 떴는지 확인한다.

import 'package:flutter_test/flutter_test.dart';

import 'package:hornet_fest/app.dart';

void main() {
  testWidgets('메인 화면이 DAY 1 타임테이블을 보여준다', (WidgetTester tester) async {
    await tester.pumpWidget(const HornetApp());

    expect(find.text('말벌 아저씨'), findsWidgets);
    expect(find.text('DAY 1'), findsOneWidget);
    expect(find.text('DAY 1 타임테이블'), findsOneWidget);
    expect(find.text('● LIVE'), findsOneWidget);
  });

  testWidgets('DAY 2를 누르면 해당 날짜 타임테이블로 바뀐다', (WidgetTester tester) async {
    await tester.pumpWidget(const HornetApp());

    await tester.tap(find.text('DAY 2'));
    await tester.pump();

    expect(find.text('DAY 2 타임테이블'), findsOneWidget);
    expect(find.text('벌집 왈츠'), findsOneWidget);
    // DAY 2에는 공연 중인 무대가 없으므로 LIVE 카드가 사라진다.
    expect(find.text('● LIVE'), findsNothing);
  });

  testWidgets('별표를 누르면 내 라인업에 담긴다', (WidgetTester tester) async {
    await tester.pumpWidget(const HornetApp());

    expect(find.text('내 라인업에 담기'), findsOneWidget);

    await tester.tap(find.text('내 라인업에 담기'));
    await tester.pump();

    expect(find.text('내 라인업에 있음'), findsOneWidget);
  });

  testWidgets('하단 탭으로 설정 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HornetApp());

    await tester.tap(find.text('설정'));
    await tester.pump();

    expect(find.text('설정 화면은 아직 준비 중'), findsOneWidget);
  });
}
