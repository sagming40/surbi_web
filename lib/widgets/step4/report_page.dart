// lib/widgets/step4/report_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/providers/score_provider.dart';
import 'report_loading.dart';
import 'report_viewer.dart';

/// Task 3-5 — "로딩이냐 완료냐"를 스스로 판단해서
/// ReportLoading 또는 ReportViewer를 보여주는 중간 관리자 위젯
class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

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
      appBar: AppBar(
        backgroundColor: Colors.white, // ⭐ 추가
        elevation: 0, // ⭐ 추가 (그림자 없이 깔끔하게)
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 30,
            color: Color(0xFF1E3A5F),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI 창업 보고서',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A5F),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('지원사업 목록은 준비 중이에요 (Task 3-6)')),
            );
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
