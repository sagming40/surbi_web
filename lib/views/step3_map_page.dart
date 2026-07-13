// lib/views/step3_map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/building_provider.dart';
import '../services/kakao_map_view_registry.dart';
import '../models/building.dart';

class Step3MapPage extends ConsumerStatefulWidget {
  final String regionCode;

  const Step3MapPage({super.key, required this.regionCode});

  @override
  ConsumerState<Step3MapPage> createState() => _Step3MapPageState();
}

class _Step3MapPageState extends ConsumerState<Step3MapPage> {
  @override
  void initState() {
    super.initState();

    onBuildingMarkerTap = (building) {
      ref.read(selectedBuildingProvider.notifier).state = building;
      _showBuildingBottomSheet(building);
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final buildings = ref.read(buildingsProvider);
      addBuildingMarkers(buildings);
    });
  }

  @override
  void dispose() {
    onBuildingMarkerTap = null;
    super.dispose();
  }

  void _showBuildingBottomSheet(Building building) {
    final scoreColor = building.previewScore >= 70
        ? Colors.green
        : (building.previewScore >= 50 ? Colors.orange : Colors.red);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  building.buildingName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        building.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.insights_outlined, size: 20, color: scoreColor),
                    const SizedBox(width: 8),
                    const Text(
                      '미리보기 점수',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${building.previewScore.toStringAsFixed(1)}점',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),

                // ⬇️ Step4 이동 버튼
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // BottomSheet 닫기
                      context.push('/step4/${building.buildingId}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A5F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'AI 창업 점수 자세히 보기',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('건물 탐색')),
      body: const HtmlElementView(viewType: 'kakao-map-view'),
    );
  }
}
