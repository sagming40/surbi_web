// lib/widgets/step4/report_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Task 3-6 ⭐ 추가
import 'package:surbi_web/providers/score_provider.dart';
import 'package:surbi_web/widgets/common/surbi_app_bar.dart'; // Task 3-6 ⭐ 추가
import 'report_loading.dart';
import 'report_viewer.dart';

/// Task 3-5 — "로딩/완료"를 스스로 판별
/// ReportLoading 또는 ReportViewer를 보여주는 중간 관리 위젯
class ReportPage extends ConsumerStatefulWidget {
  final String buildingId; // Task 3-6 ⭐ 추가

  const ReportPage({super.key, required this.buildingId}); // Task 3-6 ⭐ 수정

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  bool _isLoading = true; // 신호등 상태값 — 처음엔 항상 "로딩중"으로 시작
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 4초 뒤 (로딩 메시지 4개 × 3초 중 마지막 메시지까지는 못 보지만,
    // 실제 서비스라면 이 자리에 API 응답 대기가 들어갈 자리)
    _timer = Timer(const Duration(seconds: 12), () {
      // ⚠️ 위젯이 이미 화면에서 사라진 뒤 setState 호출하면 에러 발생
      // mounted 체크로 "아직 화면에 붙어있을 때만" 안전하게 실행
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SurbiAppBar(title: 'AI 창업 보고서'),
      body: _isLoading
          ? const ReportLoading()
          : ReportViewer(report: ref.read(reportProvider)),

      // ⭐ 로딩 중엔 버튼 자체를 안 보여주고, 결과 화면일 때만 하단에 고정
      bottomNavigationBar: _isLoading ? null : _buildBottomButton(context),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: () {
            context.push(
              '/step4/${widget.buildingId}/policies',
            ); // ⭐ SnackBar 대신 실제 이동
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF1E3A5F)),
            foregroundColor: const Color(0xFF1E3A5F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '지원사업 자세히 보기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}
