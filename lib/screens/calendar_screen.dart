import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/constants.dart';

/// 날짜별 공연/페스티벌 일정. 임시 데이터 — 나중에 서버/저장소로 교체.
/// key는 반드시 시·분 없는 DateTime(y, m, d)로 만든다 (맵 조회가 == 비교라서).
/// 밑줄 없이 public: 타임테이블 헤더("오늘의 페벌")에서도 쓴다.
final festivalEvents = <DateTime, List<String>>{
  DateTime(2026, 8, 29): ['말벌 페스트 DAY 1'],
  DateTime(2026, 8, 30): ['말벌 페스트 DAY 2'],
  DateTime(2026, 9, 12): ['그랜드 민트 페스티벌'],
  DateTime(2026, 10, 3): ['부산국제록페스티벌'],
};

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // 초기값은 전역 selectedDate에서 가져온다 (헤더와 같은 날짜로 시작).
  DateTime _selected = selectedDate.value;
  late DateTime _focused = _selected; // 캘린더가 어느 달을 보여줄지

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // 선택한 날짜의 시·분을 버리고 일 단위로 맞춰서 이벤트 조회.
    final dayKey = DateTime(_selected.year, _selected.month, _selected.day);
    final todaysEvents = festivalEvents[dayKey] ?? [];

    return Scaffold(
      body: Column(
        children: [
          Card(
            color: Colors.white,
            child: TableCalendar<String>(
              firstDay: DateTime(2026, 1, 1),
              lastDay: DateTime(2027, 12, 31),
              focusedDay: _focused,
              // isSameDay: 시·분 무시하고 같은 '날'인지 비교해주는 패키지 함수.
              selectedDayPredicate: (day) => isSameDay(day, _selected),
              // eventLoader: 각 날짜 칸마다 호출돼서, 돌려준 리스트 개수만큼
              // 날짜 밑에 점 마커를 찍어준다.
              eventLoader: (day) =>
                  festivalEvents[DateTime(day.year, day.month, day.day)] ?? [],
              onDaySelected: (selected, focused) {
                setState(() {
                  _selected = selected;
                  _focused = focused;
                });
                // 전역 ValueNotifier 갱신 → 이걸 듣고 있는 헤더가 다시 그려진다.
                selectedDate.value =
                    DateTime(selected.year, selected.month, selected.day);
              },
              onPageChanged: (focused) => _focused = focused,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.black),
                todayDecoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(color: Colors.black),
                markerDecoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Expanded(
            child: todaysEvents.isEmpty
                ? const Center(child: Text('이 날은 공연이 없어요'))
                : ListView(
                    children: [
                      for (final name in todaysEvents)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.music_note),
                            title: Text(
                              name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                                '${dayKey.month}월 ${dayKey.day}일'),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEvent(dayKey),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addEvent(DateTime dayKey) async {
    final controller = TextEditingController();
    // showModalBottomSheet<String>: 시트가 pop될 때 넘긴 값을 돌려받는다.
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        // viewInsets.bottom: 키보드 높이만큼 밀어올려서 입력창이 안 가려지게.
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: '행사명'),
                onSubmitted: (v) => Navigator.pop(context, v),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => Navigator.pop(context, controller.text),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    setState(() {
      festivalEvents.putIfAbsent(dayKey, () => []).add(name.trim());
    });
  }
}
