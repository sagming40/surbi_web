import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';

// 검색 결과나 리스트가 비어있을 때 보여줄 화면
class SurbiEmpty extends StatelessWidget {
  final String message;
  const SurbiEmpty({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            color: SurbiColors.placeholderGray,
            size: 48,
          ),
          const SizedBox(height: 12),
          // 상태 위젯 3종(empty·error·loading)은 같은 크기여야 한다.
          // 셋 다 미명시면 '우연히' 같을 뿐, 한 화면이 다른 Theme 아래
          // 놓이는 순간 갈린다.
          Text(
            message,
            style: const TextStyle(
              fontSize: SurbiText.body,
              color: SurbiColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}
