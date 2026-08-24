import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'timetable_screen.dart';

/// 캔버스에 올라간 스티커 하나. 셋 중 하나의 모습이 된다:
///  - text만: 큰 글자/이모지
///  - text + boxed: 흰 카드 모양 (타임라인 시간 카드)
///  - imagePath: 갤러리에서 가져온 사진
/// offset은 드래그하는 동안 계속 바뀌니 non-final.
class Sticker {
  Sticker({this.text, this.imagePath, this.boxed = false});

  final String? text;
  final String? imagePath;
  final bool boxed;
  Offset offset = Offset.zero;
}

/// 타임라인 꾸미기 캔버스 (인스타 스토리처럼).
/// 다음 단계: 핀치 크기·회전 → 이미지로 내보내기.
class DecorateScreen extends StatefulWidget {
  const DecorateScreen({super.key});

  @override
  State<DecorateScreen> createState() => _DecorateScreenState();
}

class _DecorateScreenState extends State<DecorateScreen> {
  final List<Sticker> _stickers = [];

  Future<void> _addSticker() async {
    final sticker = await showModalBottomSheet<Sticker>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddStickerSheet(),
    );
    if (sticker == null) return;
    setState(() {
      // 새 스티커는 화면 중앙 근처에, 개수만큼 살짝 어긋나게 놓아
      // 여러 개 추가해도 안 겹친다.
      sticker.offset = Offset(
        80 + _stickers.length * 12.0,
        200 + _stickers.length * 12.0,
      );
      _stickers.add(sticker);
    });
  }

  /// 스티커 종류에 따라 다른 모습으로 그린다.
  Widget _stickerView(Sticker s) {
    if (s.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(s.imagePath!), width: 150),
      );
    }
    if (s.boxed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          s.text!,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      );
    }
    return Text(
      s.text!,
      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack: 자식들을 겹쳐 그린다. Positioned로 좌표 지정.
      body: Stack(
        children: [
          if (_stickers.isEmpty)
            const Center(
              child: Text(
                '+ 버튼으로 스티커를 추가하고\n드래그로 움직여보세요',
                textAlign: TextAlign.center,
              ),
            ),
          for (final s in _stickers)
            Positioned(
              left: s.offset.dx,
              top: s.offset.dy,
              child: GestureDetector(
                // delta: 직전 이벤트 이후 손가락이 움직인 거리.
                // 매 프레임 offset에 더하면 손가락을 따라온다.
                onPanUpdate: (d) => setState(() => s.offset += d.delta),
                child: _stickerView(s),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSticker,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 스티커 입력 시트: 이모지 / 내 타임라인 시간 카드 / 갤러리 사진 / 텍스트.
class _AddStickerSheet extends StatefulWidget {
  const _AddStickerSheet();

  @override
  State<_AddStickerSheet> createState() => _AddStickerSheetState();
}

class _AddStickerSheetState extends State<_AddStickerSheet> {
  final _controller = TextEditingController();

  // 이모지는 그냥 글자라서 이미지 에셋 없이 그대로 스티커가 된다.
  static const _quickEmojis = ['🐝', '🎸', '🔥', '⭐', '🖤', '🍺'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return; // 취소했거나 시트가 닫힌 경우.
    Navigator.pop(context, Sticker(imagePath: picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final e in _quickEmojis)
                TextButton(
                  onPressed: () => Navigator.pop(context, Sticker(text: e)),
                  child: Text(e, style: const TextStyle(fontSize: 28)),
                ),
            ],
          ),
          const Text('내 타임라인', style: TextStyle(fontWeight: FontWeight.w700)),
          Wrap(
            spacing: 8,
            children: [
              for (final slot in myLineup)
                ActionChip(
                  label: Text('${hhmm(slot.start)} ${slot.name}'),
                  onPressed: () => Navigator.pop(
                    context,
                    Sticker(
                      text: '${hhmm(slot.start)} ${slot.name}',
                      boxed: true, // 흰 카드 모양으로.
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.photo),
            label: const Text('갤러리에서 사진 가져오기'),
          ),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: '텍스트 스티커'),
            onSubmitted: (v) =>
                v.trim().isEmpty ? null : Navigator.pop(context, Sticker(text: v.trim())),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context, Sticker(text: text));
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}
