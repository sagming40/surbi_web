// lib/widgets/step4/report_viewer.dart

import 'package:flutter/material.dart';
import 'package:surbi_web/models/report.dart';

/// Task 3-5 — LLM 보고서 출력 화면 (문서형 레이아웃)
/// 상권 요약 / 리스크 요인 / 정책 추천 3개 섹션으로 구성
class ReportViewer extends StatelessWidget {
  final Report report;

  const ReportViewer({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 헤더: 지역명 + 업종 + 생성일 ──
          Text(
            '${report.regionName} · ${report.category}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${report.createdAt} 생성',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),

          // ── 섹션 1: 상권 요약 ──
          _buildSection(
            icon: Icons.bar_chart_outlined,
            title: '상권 요약',
            content: report.summary,
          ),
          const SizedBox(height: 24),

          // ── 섹션 2: 리스크 요인 ──
          _buildSection(
            icon: Icons.warning_amber_outlined,
            title: '리스크 요인',
            content: report.riskFactors,
          ),
          const SizedBox(height: 24),

          // ── 섹션 3: 정책 추천 ──
          _buildSection(
            icon: Icons.lightbulb_outline,
            title: '정책 추천',
            content: report.policyAdvice,
          ),
        ],
      ),
    );
  }

  /// 섹션 하나 (아이콘 + 제목 + 본문) — 반복되는 구조라 헬퍼로 분리
  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1E3A5F)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A5F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
