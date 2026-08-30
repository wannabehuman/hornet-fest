// config/theme.dart — hornet 카툰 테마 토큰.
//
// spec: hornet-fest-spec.md §7(비주얼 테마)

import 'package:flutter/material.dart';

/// 앱 전역 색상 팔레트.
///
/// 생성자를 private(`._`)으로 막아둬서 `HornetColors()`로 인스턴스를 만들 수 없다.
/// 상수만 담는 네임스페이스 역할이라 인스턴스가 필요 없기 때문.
class HornetColors {
  const HornetColors._();

  /// 메인 노랑 (주황빛이 도는 말벌 노랑)
  static const hornet = Color(0xFFFFD93D);

  /// 메인 검정 (순수 검정보다 살짝 부드러운 먹색)
  static const ink = Color(0xFF1A1A1A);

  /// 화면 바닥색
  static const bg = Color(0xFFFAFAF8);

  /// 카드 등 올라오는 면
  static const surface = Color(0xFFFFFFFF);

  static const pink = Color(0xFFFFB5C8);
  static const blue = Color(0xFF7EB6FF);
  static const cream = Color(0xFFFFF8E7);

  /// 공연 중 표시용 빨강
  static const live = Color(0xFFE0442F);
}

/// 스티커처럼 툭 튀어나와 보이는 그림자.
///
/// `blurRadius: 0`이 핵심 — 흐림이 없어야 종이 스티커 느낌이 난다.
/// 일반 머티리얼 그림자는 blur가 들어가서 물렁해 보인다.
List<BoxShadow> stickerShadow({double offset = 4}) => [
      BoxShadow(
        color: HornetColors.ink,
        offset: Offset(offset, offset),
        blurRadius: 0,
      ),
    ];

/// 카툰 스타일 검은 테두리.
Border inkBorder({double width = 2}) =>
    Border.all(color: HornetColors.ink, width: width);

/// 카드/버튼 공통 라운드 값.
const hornetRadius = BorderRadius.all(Radius.circular(16));

/// 앱 전역 테마.
///
/// 색을 위젯마다 하드코딩하지 않고 여기 한 곳에서 정하면,
/// 나중에 팔레트를 바꿀 때 이 파일만 고치면 된다.
ThemeData hornetTheme() {
  // fromSeed가 씨앗 색으로 팔레트 전체를 자동 생성하되,
  // 뒤에 직접 넘긴 값들은 자동 생성분을 덮어쓴다.
  final scheme = ColorScheme.fromSeed(
    seedColor: HornetColors.hornet,
    primary: HornetColors.hornet,
    onPrimary: HornetColors.ink,
    surface: HornetColors.surface,
    onSurface: HornetColors.ink,
    error: HornetColors.live,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: HornetColors.bg,
    // 카툰 톤이라 기본 글자를 전부 먹색 + 두껍게.
    textTheme: Typography.blackMountainView.apply(
      bodyColor: HornetColors.ink,
      displayColor: HornetColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: HornetColors.hornet,
      foregroundColor: HornetColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: HornetColors.ink,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),
  );
}
