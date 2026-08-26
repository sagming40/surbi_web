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
          Text(message, style: const TextStyle(color: SurbiColors.textGray)),
        ],
      ),
    );
  }
}
