import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/models/score_result.dart';

class ShapBarChart extends StatelessWidget {
  final List<ShapFactor> factors;

  const ShapBarChart({super.key, required this.factors});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: factors.map((factor) => _buildRow(factor)).toList(),
    );
  }

  Widget _buildRow(ShapFactor factor) {
    // 절댓값 비율 계산 (0~1 사이로 제한)
    final ratio = (factor.value.abs() / factor.maxScore).clamp(0.0, 1.0);
    final isPositive = factor.value >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요인 이름표 (예: 유동인구)
          Text(
            factor.name,
            style: const TextStyle(fontSize: 13, color: SurbiColors.textGray),
          ),
          const SizedBox(height: 4),

          // 막대 + 가운데 기준선
          SizedBox(
            height: 20,
            child: Row(
              children: [
                // 왼쪽 절반 — 음수(감점) 자리
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: isPositive ? 0 : ratio,
                      child: Container(
                        decoration: BoxDecoration(
                          color: SurbiColors.shapNegative,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 가운데 기준선 (0점 지점)
                Container(width: 1.5, height: 20, color: Colors.grey.shade400),

                // 오른쪽 절반 — 양수(기여) 자리
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: isPositive ? ratio : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: SurbiColors.shapPositive,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // 숫자 값 표시 (예: +16, -10)
          Text(
            isPositive ? '+${factor.value.toInt()}' : '${factor.value.toInt()}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPositive
                  ? SurbiColors.shapPositive
                  : SurbiColors.shapNegative,
            ),
          ),
        ],
      ),
    );
  }
}
