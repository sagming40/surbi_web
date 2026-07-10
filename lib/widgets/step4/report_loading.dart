// lib/widgets/step4/report_loading.dart

import 'dart:async';
import 'package:flutter/material.dart';

/// Task 3-5 — LLM 보고서 생성 중 보여줄 단계별 로딩 위젯
/// 3초마다 메시지가 자동으로 바뀜 (10~30초 소요되는 작업이라 단순 스피너 대신 사용)
class ReportLoading extends StatefulWidget {
  const ReportLoading({super.key});

  @override
  State<ReportLoading> createState() => _ReportLoadingState();
}

class _ReportLoadingState extends State<ReportLoading> {
  // 3초마다 순서대로 보여줄 메시지 목록
  static const List<String> _messages = [
    '상권 데이터 분석 중...',
    'AI 모델 추론 중...',
    '보고서 작성 중...',
    '거의 다 됐어요!',
  ];

  int _currentIndex = 0; // 지금 몇번째 메시지를 보여주고 있는지
  Timer? _timer; // 타이머를 나중에 끌 수 있도록 변수에 저장해둠

  @override
  void initState() {
    super.initState();
    // 위젯이 화면에 처음 나타날 때 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        // 마지막 메시지에 도달하면 더 이상 넘어가지 않고 그대로 유지
        if (_currentIndex < _messages.length - 1) {
          _currentIndex++;
        }
      });
    });
  }

  @override
  void dispose() {
    // ⚠️ 중요: 위젯이 사라질 때 타이머도 반드시 꺼줘야 함
    // 타이머를 끄지 않을 경우 이미 없어진 화면을 계속 업데이트 하려다 에러 발생
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF1E3A5F)),
          const SizedBox(height: 24),
          Text(
            _messages[_currentIndex],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }
}
