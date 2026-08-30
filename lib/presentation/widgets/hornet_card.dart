import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// 흰 바탕 + 검은 테두리 + 스티커 그림자 카드.
///
/// 화면마다 Container/BoxDecoration을 반복해서 쓰지 않으려고 뽑아둔 공통 위젯.
/// 자식(child)만 갈아끼우면 어디서든 같은 생김새가 나온다.
class HornetCard extends StatelessWidget {
  const HornetCard({
    super.key,
    required this.child,
    this.color = HornetColors.surface,
    this.padding = const EdgeInsets.all(16),
    this.borderWidth = 2,
    this.shadowOffset = 4,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double borderWidth;
  final double shadowOffset;

  /// null이면 탭에 반응하지 않는다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: inkBorder(width: borderWidth),
        borderRadius: hornetRadius,
        boxShadow: stickerShadow(offset: shadowOffset),
      ),
      child: child,
    );

    // onTap이 없으면 GestureDetector로 감싸지 않고 그대로 반환.
    if (onTap == null) return box;

    return GestureDetector(onTap: onTap, child: box);
  }
}

/// 라운드 알약 모양 라벨. 무대 이름, LIVE 배지 등에 사용.
class HornetPill extends StatelessWidget {
  const HornetPill({
    super.key,
    required this.label,
    required this.color,
    this.textColor = HornetColors.ink,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: inkBorder(width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
