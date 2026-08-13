// di/injector.dart — GetIt 기반 의존성 주입.
//
// 여기서 할 일(직접 구현):
//  - GetIt 인스턴스 준비 후 setupInjector() 작성
//  - 등록 순서: datasource → repository(impl) → usecase → service
//  - main.dart에서 runApp 전에 호출
//
// 참고: eGovFrame 공식 예제 egovframe-mobile-device-api의 device-api-app/lib/di
//       구조를 열어 대조하며 동일 패턴으로 흉내 내기(커리큘럼 3단계).
// 패키지 필요: get_it (pubspec.yaml에 추가)
