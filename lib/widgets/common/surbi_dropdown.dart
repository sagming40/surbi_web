// lib/widgets/common/surbi_dropdown.dart

import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';

/// 버튼 바로 아래에 항상 붙어서 펼쳐지는 커스텀 드롭다운.
/// DropdownButtonFormField와 달리 화면 잘림 회피를 위해 위로 뒤집히지 않음.
class SurbiDropdown<T> extends StatefulWidget {
  final T? value;
  final String hintText;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final ValueChanged<T>? onChanged; // null이면 비활성화(회색 처리)
  final double maxMenuHeight;
  final bool openUpward; // ⬅️ 추가 — true면 버튼 위쪽으로 펼침 (하단 바 전용)

  /// 메뉴가 열리면 true, 닫히면 false로 호출된다. (2026-08-20 추가)
  ///
  /// 이 위젯은 "메뉴가 열렸다"는 사실만 알려줄 뿐, 바깥에서 뭘 하는지는 모른다.
  /// 지도 화면에서는 이 신호를 받아 지도의 드래그·휠을 잠그는 데 사용한다.
  final ValueChanged<bool>? onMenuVisibilityChanged;

  const SurbiDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.maxMenuHeight = 280,
    this.openUpward = false, // ⬅️ 추가
    this.onMenuVisibilityChanged, // ⬅️ 추가
  });

  @override
  State<SurbiDropdown<T>> createState() => _SurbiDropdownState<T>();
}

class _SurbiDropdownState<T> extends State<SurbiDropdown<T>> {
  // 버튼 위치를 기준점으로 등록하기 위한 키
  final LayerLink _layerLink = LayerLink();
  // 지금 화면에 떠 있는 오버레이(메뉴)를 기억해뒀다가 나중에 지우기 위한 변수
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  bool get _isEnabled => widget.onChanged != null;

  void _toggleMenu() {
    if (!_isEnabled) return; // 비활성화 상태면 아무 것도 안 함

    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // ① 화면 전체를 덮는 투명 레이어 — 메뉴 바깥을 탭하면 닫히게 하는 역할
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeMenu,
              ),
            ),
            // ② 실제 메뉴 — 버튼 위치를 따라다니며 바로 아래에 고정
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              // ⬇️ 추가 — 위로 펼칠 땐 메뉴의 "아래쪽"을 버튼의 "위쪽"에 붙임
              targetAnchor: widget.openUpward
                  ? Alignment.topLeft
                  : Alignment.topLeft,
              followerAnchor: widget.openUpward
                  ? Alignment.bottomLeft
                  : Alignment.topLeft,
              offset: widget.openUpward
                  ? const Offset(0, -8)
                  : const Offset(0, 52), // 버튼 높이만큼 아래로 (버튼 높이에 맞춰 조정)
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(SurbiRadius.card),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxMenuHeight),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.items.map((item) {
                        return InkWell(
                          onTap: () {
                            widget.onChanged?.call(item);
                            _closeMenu();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Text(widget.labelBuilder(item)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
    widget.onMenuVisibilityChanged?.call(true); // ⬅️ 추가 — "메뉴 열렸음" 알림
  }

  void _closeMenu() {
    if (_overlayEntry == null) return; // ⬅️ 추가 — 이미 닫혀 있으면 중복 알림 방지

    _overlayEntry!.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
    widget.onMenuVisibilityChanged?.call(false); // ⬅️ 추가 — "메뉴 닫혔음" 알림
  }

  @override
  void dispose() {
    // 화면이 사라질 때 오버레이가 남아있으면 메모리 누수 + 크래시 위험 → 반드시 정리
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      // ⬅️ 추가 — 메뉴가 열린 채로 화면을 떠나도 바깥의 잠금이 풀리도록 알림
      // (dispose 중이라 setState는 호출하지 않음)
      widget.onMenuVisibilityChanged?.call(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.value != null
        ? widget.labelBuilder(widget.value as T)
        : widget.hintText;

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleMenu,
        borderRadius: BorderRadius.circular(SurbiRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _isEnabled ? Colors.white : SurbiColors.placeholderGray,
            borderRadius: BorderRadius.circular(SurbiRadius.pill),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    color: widget.value != null
                        ? Colors.black
                        : SurbiColors.textGray,
                  ),
                ),
              ),
              Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: SurbiColors.textGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
