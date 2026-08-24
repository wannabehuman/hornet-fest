import 'package:flutter/material.dart';

/// 타임테이블 한 칸: 아티스트 하나의 공연 정보.
class ArtistSlot {
  const ArtistSlot({
    required this.name,
    required this.stage,
    required this.start,
    required this.end,
  });

  final String name;
  final String stage;
  final DateTime start;
  final DateTime end;
}

/// 화면 확인용 임시 데이터. 타임테이블 업로드 기능 만들면 교체.
final sampleLineup = [
  ArtistSlot(
    name: '실리카겔',
    stage: 'MAIN STAGE',
    start: DateTime(2026, 8, 29, 13, 0),
    end: DateTime(2026, 8, 29, 13, 50),
  ),
  ArtistSlot(
    name: '새소년',
    stage: 'HONEY STAGE',
    start: DateTime(2026, 8, 29, 14, 0),
    end: DateTime(2026, 8, 29, 14, 50),
  ),
  ArtistSlot(
    name: '잔나비',
    stage: 'MAIN STAGE',
    start: DateTime(2026, 8, 29, 15, 30),
    end: DateTime(2026, 8, 29, 16, 20),
  ),
  ArtistSlot(
    name: 'YB',
    stage: 'MAIN STAGE',
    start: DateTime(2026, 8, 29, 17, 0),
    end: DateTime(2026, 8, 29, 18, 0),
  ),
  ArtistSlot(
    name: '검정치마',
    stage: 'HONEY STAGE',
    start: DateTime(2026, 8, 29, 18, 30),
    end: DateTime(2026, 8, 29, 19, 20),
  ),
];

/// 내 타임라인 (샘플 + 직접 추가한 슬롯). 꾸미기 화면에서도 갖다 쓴다.
final myLineup = <ArtistSlot>[...sampleLineup];

/// DateTime → "13:00" 형태 문자열.
String hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  /// 픽한 아티스트 이름 모음. Set이라 중복이 없고 포함 여부 확인이 빠르다.
  final Set<String> _picked = {};

  Future<void> _addSlot() async {
    // showModalBottomSheet는 Future를 리턴한다.
    // 시트 안에서 Navigator.pop(context, slot)한 값이 여기 await 결과로 온다.
    final slot = await showModalBottomSheet<ArtistSlot>(
      context: context,
      isScrollControlled: true, // 키보드 올라올 때 시트가 같이 밀려 올라가게.
      builder: (context) => const _AddSlotSheet(),
    );
    if (slot == null) return; // 그냥 닫으면 null.
    setState(() {
      myLineup.add(slot);
      myLineup.sort((a, b) => a.start.compareTo(b.start));
    });
  }

  void _togglePick(String name) {
    setState(() {
      // 이미 픽했으면 해제, 아니면 추가.
      if (!_picked.add(name)) {
        _picked.remove(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 헤더(오늘의 페벌)는 HomeShell이 모든 탭 공통으로 보여준다.
      // ListView.builder: 화면에 보이는 칸만 그때그때 만들어서 목록이
      // 길어져도 성능이 안 죽는다. 목록엔 기본으로 이걸 쓴다.
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: myLineup.length,
        itemBuilder: (context, index) {
          final slot = myLineup[index];
          final isPicked = _picked.contains(slot.name);
          return Card(
            child: ListTile(
              leading: Text(
                hhmm(slot.start),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              title: Text(
                slot.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${slot.stage} · ~${hhmm(slot.end)}'),
              trailing: IconButton(
                icon: Icon(
                  isPicked ? Icons.star : Icons.star_border,
                  color: isPicked
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                onPressed: () => _togglePick(slot.name),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSlot,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 슬롯 입력 바텀시트. 입력값(컨트롤러, 선택한 시간)이 있으니 Stateful.
class _AddSlotSheet extends StatefulWidget {
  const _AddSlotSheet();

  @override
  State<_AddSlotSheet> createState() => _AddSlotSheetState();
}

class _AddSlotSheetState extends State<_AddSlotSheet> {
  final _nameController = TextEditingController();
  final _stageController = TextEditingController();
  TimeOfDay _start = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 13, minute: 50);

  @override
  void dispose() {
    // 컨트롤러는 위젯이 사라져도 자동으로 안 지워져서 직접 정리해야 메모리가 안 샌다.
    _nameController.dispose();
    _stageController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null || !mounted) return; // await 뒤엔 mounted 확인.
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return; // 이름 없으면 무시.
    // 축제 날짜(2026-08-29)에 선택한 시·분만 얹는다.
    DateTime at(TimeOfDay t) => DateTime(2026, 8, 29, t.hour, t.minute);
    Navigator.pop(
      context,
      ArtistSlot(
        name: name,
        stage: _stageController.text.trim(),
        start: at(_start),
        end: at(_end),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // viewInsets.bottom = 키보드 높이. 이만큼 띄워야 입력칸이 안 가려진다.
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용 높이만큼만 차지.
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '아티스트명'),
          ),
          TextField(
            controller: _stageController,
            decoration: const InputDecoration(labelText: '스테이지'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: () => _pickTime(isStart: true),
                child: Text('시작 ${_start.format(context)}'),
              ),
              TextButton(
                onPressed: () => _pickTime(isStart: false),
                child: Text('종료 ${_end.format(context)}'),
              ),
            ],
          ),
          FilledButton(
            onPressed: _submit,
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}
