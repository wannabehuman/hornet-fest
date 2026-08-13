// services/notifications.dart — 로컬 예약 알림 래퍼 (이 앱의 심장).
//
// 여기서 할 일(직접 구현):
//  - flutter_local_notifications 초기화(+ timezone 초기화)
//  - schedule(id, atTime, title, body): 찜하는 순간 start-leadMinutes에 zonedSchedule
//  - cancel(id): 찜 해제 시 예약 취소
//  - 커스텀 사운드 채널(Android)/sound(iOS), 권한 요청
//
// 함정: Android 13+ 알림 권한 + SCHEDULE_EXACT_ALARM, iOS 권한 요청.
// 핵심 개념: "켜졌을 때 계산해서 울림"이 아니라 "미리 OS에 예약". (spec §6.2)
