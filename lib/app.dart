// app.dart — MaterialApp 루트 + 하단 탭 셸.
//
// spec: hornet-fest-spec.md §5(화면), §8(구조)

import 'package:flutter/material.dart';

import 'config/theme.dart';
import 'presentation/screens/home_screen.dart';

class HornetApp extends StatelessWidget {
  const HornetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '말벌 아저씨',
      theme: hornetTheme(),
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    );
  }
}

/// 하단 탭 3개를 감싸는 셸.
///
/// 탭을 바꿔도 각 화면의 State를 살려두려고 IndexedStack을 쓴다.
/// (if/else로 갈아끼우면 탭 이동할 때마다 화면이 처음부터 다시 만들어진다)
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // const 리스트로 한 번만 만들어 재사용.
  static const _tabs = <Widget>[
    HomeScreen(),
    _Placeholder(title: '내 라인업', icon: Icons.star_rounded),
    _Placeholder(title: '설정', icon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Container(
        // 탭바 위쪽 검은 선.
        decoration: const BoxDecoration(
          color: HornetColors.surface,
          border: Border(
            top: BorderSide(color: HornetColors.ink, width: 3),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _NavItem(
                label: '타임라인',
                icon: Icons.view_agenda_rounded,
                selected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _NavItem(
                label: '내 라인업',
                icon: Icons.star_rounded,
                selected: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
              _NavItem(
                label: '설정',
                icon: Icons.settings_rounded,
                selected: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        // 투명 영역도 탭을 받도록 — 기본값이면 글자/아이콘만 눌린다.
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 선택된 탭만 노란 알약 배경을 깔아준다.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? HornetColors.hornet : Colors.transparent,
                  border: selected ? inkBorder(width: 2) : null,
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                ),
                child: Icon(icon, size: 22, color: HornetColors.ink),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: HornetColors.ink,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 아직 안 만든 탭 자리.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: HornetColors.ink),
            const SizedBox(height: 12),
            Text(
              '$title 화면은 아직 준비 중',
              style: const TextStyle(
                color: HornetColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
