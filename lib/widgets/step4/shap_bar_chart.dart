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
    final barColor = isPositive
        ? SurbiColors.shapPositive
        : SurbiColors.shapNegative;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요인 이름표 (예: 유동인구)
          // 이름표 + 숫자를 한 줄에 나란히
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Tooltip(
                message: _friendlyDescription(factor.name),
                triggerMode: TooltipTriggerMode.longPress, // 길게 눌러야 뜨게
                showDuration: const Duration(seconds: 3), // 3초 보여주고 사라짐
                child: Text(
                  factor.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: SurbiColors.textGray,
                  ),
                ),
              ),
              // 숫자 값 표시 (예: +16, -10)
              Text(
                isPositive
                    ? '+${factor.value.toInt()}'
                    : '${factor.value.toInt()}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

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
                Container(
                  width: 1.5,
                  height: 24, // 막대(20)보다 살짝 크게 키워서 도드라지게
                  color: Colors.grey.shade500, // 회색 복귀, 살짝 더 진하게
                ),

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
        ],
      ),
    );
  }

  // 딱딱한 항목명을 친절한 설명으로 바꿔주는 함수
  // ⚠️ 임시 하드코딩 - BE에서 이 설명까지 함께 내려줄지,
  // FE에서 고정 문구로 관리할지 협의 필요
  String _friendlyDescription(String factorName) {
    switch (factorName) {
      case '유동인구':
        return '이 지역에 하루동안 오가는 사람이 얼마나 되는지';
      case '경쟁 강도':
        return '주변에 비슷한 업종의 가게가 얼마나 몰려 있는지';
      case '정책 지원 적합도':
        return '내가 받을 수 있는 정부 지원사업과 얼마나 잘 맞는지';
      default:
        return '';
    }
  }
}
