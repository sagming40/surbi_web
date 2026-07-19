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

  const SurbiDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.maxMenuHeight = 280,
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
              offset: const Offset(0, 52), // 버튼 높이만큼 아래로 (버튼 높이에 맞춰 조정)
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
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  void dispose() {
    // 화면이 사라질 때 오버레이가 남아있으면 메모리 누수 + 크래시 위험 → 반드시 정리
    _overlayEntry?.remove();
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
