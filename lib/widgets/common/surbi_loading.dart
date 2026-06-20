import 'package:flutter/material.dart';

// API에서 데이터를 불러오는 동안 보여줄 화면
class SurbiLoading extends StatelessWidget {
  final String? message;
  const SurbiLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF1565C0)),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
