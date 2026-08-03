// lib/widgets/step4/report_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/providers/score_provider.dart';
import 'report_loading.dart';
import 'report_viewer.dart';

/// Task 3-5 — "로딩/완료"를 스스로 판별
/// ReportLoading 또는 ReportViewer를 보여주는 중간 관리 위젯
class ReportPage extends ConsumerStatefulWidget {
  final String buildingId;

  const ReportPage({super.key, required this.buildingId});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 12), () {
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
    // ⭐ Scaffold 제거 — Step4Shell이 이미 화면 틀을 담당
    return _isLoading
        ? const ReportLoading()
        : ReportViewer(report: ref.read(reportProvider));
  }
}
