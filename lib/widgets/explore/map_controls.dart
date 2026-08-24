// lib/widgets/explore/map_controls.dart

import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';

/// 지도 우상단에 얹는 조작 버튼 묶음 — 확대 / 축소 / 일반↔위성
///
/// 이 위젯은 **어떤 지도를 조작하는지 모른다.** 버튼이 눌렸다는 사실만 콜백으로
/// 알리고, 실제로 어느 지도를 움직일지는 쓰는 화면이 정한다.
/// (SurbiDropdown.onMenuVisibilityChanged와 같은 원칙 — 공용 위젯은 특정 화면의
///  사정을 알지 않는다)
///
/// 다만 "지금 위성인지"는 버튼 아이콘을 고르기 위한 **자기 표시 상태**라
/// 위젯이 직접 들고 있는다. 바깥에는 바뀐 값만 통지한다.
class MapControls extends StatefulWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final ValueChanged<bool> onSkyviewChanged;

  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onSkyviewChanged,
  });

  @override
  State<MapControls> createState() => _MapControlsState();
}

class _MapControlsState extends State<MapControls> {
  bool _isSkyview = false;

  void _toggleSkyview() {
    setState(() => _isSkyview = !_isSkyview);
    widget.onSkyviewChanged(_isSkyview);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ControlButton(icon: Icons.add, onTap: widget.onZoomIn),
        const SizedBox(height: 6),
        _ControlButton(icon: Icons.remove, onTap: widget.onZoomOut),
        const SizedBox(height: 12),
        _ControlButton(
          // 지금 상태가 아니라 "누르면 무엇이 되는지"를 아이콘으로 보여준다
          icon: _isSkyview
              ? Icons.map_outlined
              : Icons.satellite_alt_outlined,
          onTap: _toggleSkyview,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: SurbiColors.accent),
        ),
      ),
    );
  }
}
