// core/constants.dart — 앱 전역 상수.
//
// 여기서 할 일(직접 구현):
//  - 기본 리드타임(7분), 리드타임 범위(1~60)
//  - 진동 패턴 배열(HORNET_PATTERN)
//  - 하루 표시 범위(예: 12:00~24:00) 등 타임라인 그리드 상수

import 'package:flutter/foundation.dart';

/// 헤더 인사말에 쓰는 사용자 이름. 설정 탭 만들면 저장값으로 교체.
const userName = '말벌 아저씨';

/// 캘린더에서 선택한 날짜. ValueNotifier: 값이 바뀌면 듣고 있는
/// 위젯(헤더의 날짜 표시)만 알아서 다시 그려진다. 시·분 없는 날짜만 넣을 것.
final selectedDate = ValueNotifier<DateTime>(DateTime(2026, 8, 29));
