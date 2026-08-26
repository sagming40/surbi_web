import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';

// API 호출 실패했을 때 보여줄 화면
class SurbiError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry; // 재시도 버튼
  const SurbiError({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: SurbiColors.bad, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            // 상태 위젯 3종(empty·error·loading)과 같은 크기
            style: const TextStyle(
              fontSize: SurbiText.body,
              color: SurbiColors.textPrimary,
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: SurbiColors.accent),
              child: const Text('다시 시도'),
            ),
        ],
      ),
    );
  }
}
