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
      appBar: AppBar(title: const Text('AI 창업 보고서')),
      body: _isLoading
          ? const ReportLoading()
          : ReportViewer(report: ref.read(reportProvider)),
    );
  }
}
