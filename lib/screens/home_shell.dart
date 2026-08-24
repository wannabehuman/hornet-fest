import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants.dart';
import 'calendar_screen.dart';
import 'decorate_screen.dart';
import 'timetable_screen.dart';

/// 하단 탭 셸: 탭 전환만 담당. 내용은 각 탭의 화면이 채운다.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 1; // 시작 탭: 타임테이블

  // 탭 아이콘: 선택되면 채워진 버전, 아니면 외곽선 버전.
  static const _filledIcons = [
    Icons.calendar_month,
    Icons.view_agenda,
    Icons.image,
    Icons.settings,
  ];
  static const _outlinedIcons = [
    Icons.calendar_month_outlined,
    Icons.view_agenda_outlined,
    Icons.image_outlined,
    Icons.settings_outlined,
  ];
  static const _labels = ['캘린더', '타임테이블', '스크린', '설정'];

  static const _screens = <Widget>[
    CalendarScreen(),
    TimetableScreen(),
    DecorateScreen(),
    _PlaceholderScreen(title: '설정'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 헤더(오늘의 페벌)는 모든 탭에서 보여야 하니 셸이 들고 있는다.
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _FestHeader(),
            ),
          ),
          // IndexedStack: 4개 화면을 전부 살려둔 채 하나만 보여준다.
          // 탭을 옮겨도 각 화면의 State(픽, 선택 날짜 등)가 유지됨.
          Expanded(child: IndexedStack(index: _index, children: _screens)),
        ],
      ),
      // 직접 만든 알약 네비게이션. NavigationBar는 인디케이터 높이가
      // 32px 고정이라 원하는 모양이 안 나와서 손수 그린다.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              for (var i = 0; i < _filledIcons.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque, // 빈 여백도 탭 인식
                    onTap: () => setState(() => _index = i),
                    child: Center(
                      child: Semantics(
                        label: _labels[i],
                        button: true,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 60,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _index == i
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: AnimatedScale(
                            scale: _index == i ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack, // 살짝 튀는 느낌
                            child: Icon(
                              _index == i ? _filledIcons[i] : _outlinedIcons[i],
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 검은 라운드 헤더. 왼쪽: 2초마다 교대되는 문구
/// (오늘의 페벌 → 곧 공연 아티스트), 오른쪽: 캘린더에서 선택한 날짜.
class _FestHeader extends StatefulWidget {
  const _FestHeader();

  @override
  State<_FestHeader> createState() => _FestHeaderState();
}

class _FestHeaderState extends State<_FestHeader> {
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // 2초마다 문구 교대. setState만 하면 build가 다음 문구를 고른다.
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() => _page++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머도 컨트롤러처럼 직접 정리해야 한다.
    super.dispose();
  }

  /// 교대할 문구 목록. [노란 부분, 흰 부분] 쌍으로 만든다.
  List<List<String>> _messages() {
    final now = DateTime.now();
    final todays = festivalEvents[DateTime(now.year, now.month, now.day)];

    // 다음 공연: 라인업(시간순 정렬됨)에서 지금 이후 첫 슬롯.
    ArtistSlot? upcoming;
    for (final s in myLineup) {
      if (s.start.isAfter(now)) {
        upcoming = s;
        break;
      }
    }

    return [
      if (todays != null && todays.isNotEmpty)
        ['오늘의 페벌 - ', "'${todays.first}'"]
      else
        [userName, ' 행복하기'],
      if (upcoming != null)
        ['곧 공연 - ', '${upcoming.name} ${hhmm(upcoming.start)}'],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messages();
    final msg = messages[_page % messages.length];
    final yellow = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            // AnimatedSwitcher: child가 다른 위젯으로 바뀌면 fade로 교차.
            // key가 달라야 "다른 위젯"으로 인식한다.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text.rich(
                key: ValueKey(msg[0] + msg[1]),
                TextSpan(
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(text: msg[0], style: TextStyle(color: yellow)),
                    TextSpan(
                        text: msg[1],
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // ValueListenableBuilder: selectedDate.value가 바뀔 때
          // 이 부분만 다시 그려진다 (setState 없이).
          ValueListenableBuilder<DateTime>(
            valueListenable: selectedDate,
            builder: (context, d, _) => Text(
              '${d.month}/${d.day}',
              style: TextStyle(
                color: yellow,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 아직 안 만든 탭의 자리 표시용 화면.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$title — 준비 중')),
    );
  }
}
