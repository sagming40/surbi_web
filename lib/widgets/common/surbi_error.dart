import 'package:flutter/material.dart';

// API 호줓 실패했을 때 보여줄 화면
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
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
