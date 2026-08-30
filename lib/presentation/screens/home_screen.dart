import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../widgets/hornet_card.dart';

/// 타임라인(메인) 화면.
///
/// spec: hornet-fest-spec.md §5(화면)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// 타임라인 한 칸.
///
/// TODO: domain/entities 로 옮기고 datasource 에서 받아오기.
///       지금은 화면 잡는 게 목적이라 더미 데이터로 둔다.
class _Slot {
  const _Slot({
    required this.id,
    required this.time,
    required this.artist,
    required this.stage,
    required this.stageColor,
    this.isLive = false,
  });

  final String id;
  final String time;
  final String artist;
  final String stage;
  final Color stageColor;
  final bool isLive;
}

const _lineupByDay = <int, List<_Slot>>{
  1: [
    _Slot(
      id: 'd1-1',
      time: '17:20',
      artist: '검은 말벌단',
      stage: 'HORNET',
      stageColor: HornetColors.hornet,
      isLive: true,
    ),
    _Slot(
      id: 'd1-2',
      time: '18:10',
      artist: '오후 다섯시의 소음',
      stage: 'HIVE',
      stageColor: HornetColors.pink,
    ),
    _Slot(
      id: 'd1-3',
      time: '19:00',
      artist: 'Yellow Jacket',
      stage: 'NEST',
      stageColor: HornetColors.blue,
    ),
    _Slot(
      id: 'd1-4',
      time: '20:30',
      artist: '말벌 아저씨',
      stage: 'HORNET',
      stageColor: HornetColors.hornet,
    ),
    _Slot(
      id: 'd1-5',
      time: '21:40',
      artist: '자정의 침',
      stage: 'HIVE',
      stageColor: HornetColors.pink,
    ),
  ],
  2: [
    _Slot(
      id: 'd2-1',
      time: '16:00',
      artist: '벌집 왈츠',
      stage: 'NEST',
      stageColor: HornetColors.blue,
    ),
    _Slot(
      id: 'd2-2',
      time: '18:40',
      artist: '스팅어스',
      stage: 'HORNET',
      stageColor: HornetColors.hornet,
    ),
    _Slot(
      id: 'd2-3',
      time: '20:00',
      artist: '여왕벌 세션',
      stage: 'HIVE',
      stageColor: HornetColors.pink,
    ),
  ],
};

class _HomeScreenState extends State<HomeScreen> {
  /// 선택된 날짜(DAY 1 / DAY 2).
  int _day = 1;

  /// 내 라인업에 담은 공연 id 모음.
  ///
  /// Set은 중복을 자동으로 걸러주고 contains가 빠르다.
  final Set<String> _myLineup = {};

  void _toggleLineup(String id) {
    setState(() {
      // 있으면 빼고 없으면 넣는다 = 별표 토글.
      if (!_myLineup.remove(id)) _myLineup.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final slots = _lineupByDay[_day] ?? const <_Slot>[];

    // firstWhere는 못 찾으면 예외를 던지므로 orElse 대신
    // where().isEmpty 체크로 안전하게 꺼낸다.
    final liveSlots = slots.where((s) => s.isLive);
    final live = liveSlots.isEmpty ? null : liveSlots.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('말벌 아저씨'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            tooltip: '아티스트 검색',
          ),
          const SizedBox(width: 4),
        ],
        // AppBar 아래 검은 선 한 줄 — 카툰 테마의 아웃라인 느낌을 이어준다.
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3),
          child: ColoredBox(
            color: HornetColors.ink,
            child: SizedBox(height: 3, width: double.infinity),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _DaySelector(
            selected: _day,
            onChanged: (day) => setState(() => _day = day),
          ),
          const SizedBox(height: 24),
          if (live != null) ...[
            const _SectionLabel('지금 무대 위'),
            const SizedBox(height: 10),
            _LiveCard(
              slot: live,
              isSaved: _myLineup.contains(live.id),
              onToggle: () => _toggleLineup(live.id),
            ),
            const SizedBox(height: 28),
          ],
          _SectionLabel('DAY $_day 타임테이블'),
          const SizedBox(height: 10),
          // ListView 안에 또 ListView를 넣으면 스크롤이 충돌하므로,
          // 리스트를 map으로 펼쳐서 children에 바로 꽂는다.
          for (final slot in slots) ...[
            _SlotCard(
              slot: slot,
              isSaved: _myLineup.contains(slot.id),
              onToggle: () => _toggleLineup(slot.id),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// 섹션 제목.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: HornetColors.ink,
        fontSize: 15,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.2,
      ),
    );
  }
}

/// DAY 1 / DAY 2 전환 버튼.
class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final day in _lineupByDay.keys) ...[
          Expanded(
            child: HornetCard(
              onTap: () => onChanged(day),
              // 선택된 쪽만 노랑으로 채우고, 나머지는 흰 카드 그대로.
              color: day == selected ? HornetColors.hornet : HornetColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shadowOffset: day == selected ? 4 : 2,
              child: Center(
                child: Text(
                  'DAY $day',
                  style: const TextStyle(
                    color: HornetColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          if (day != _lineupByDay.keys.last) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

/// 지금 공연 중인 무대를 크게 보여주는 카드.
class _LiveCard extends StatelessWidget {
  const _LiveCard({
    required this.slot,
    required this.isSaved,
    required this.onToggle,
  });

  final _Slot slot;
  final bool isSaved;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return HornetCard(
      borderWidth: 3,
      shadowOffset: 6,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HornetPill(
                label: '● LIVE',
                color: HornetColors.live,
                textColor: Colors.white,
              ),
              const SizedBox(width: 8),
              HornetPill(label: slot.stage, color: slot.stageColor),
              const Spacer(),
              Text(
                slot.time,
                style: const TextStyle(
                  color: HornetColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            slot.artist,
            style: const TextStyle(
              color: HornetColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StickerButton(
                  label: isSaved ? '내 라인업에 있음' : '내 라인업에 담기',
                  icon: isSaved ? Icons.star : Icons.star_border,
                  color: isSaved ? HornetColors.ink : HornetColors.hornet,
                  textColor: isSaved ? HornetColors.hornet : HornetColors.ink,
                  onTap: onToggle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 타임테이블 한 줄짜리 카드.
class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.isSaved,
    required this.onToggle,
  });

  final _Slot slot;
  final bool isSaved;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return HornetCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: () {}, // TODO: 아티스트 상세 바텀시트 (spec §5.3)
      child: Row(
        children: [
          // 시간 — 폭을 고정해야 아래 카드들과 세로줄이 맞는다.
          SizedBox(
            width: 52,
            child: Text(
              slot.time,
              style: const TextStyle(
                color: HornetColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            width: 2,
            height: 40,
            margin: const EdgeInsets.only(right: 14),
            color: HornetColors.ink,
          ),
          // Expanded가 남는 가로 공간을 전부 먹어서 별 버튼을 오른쪽 끝으로 민다.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HornetColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                HornetPill(label: slot.stage, color: slot.stageColor),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isSaved ? Icons.star_rounded : Icons.star_border_rounded,
              color: isSaved ? HornetColors.hornet : HornetColors.ink,
              size: 28,
            ),
            tooltip: isSaved ? '내 라인업에서 빼기' : '내 라인업에 담기',
          ),
        ],
      ),
    );
  }
}

/// 카툰 톤 버튼. HornetCard와 같은 테두리/그림자를 쓴다.
class _StickerButton extends StatelessWidget {
  const _StickerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HornetCard(
      onTap: onTap,
      color: color,
      shadowOffset: 3,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
