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
          // ── 헤더: 지역명 + 업종 + 생성일 (카드형 / 💡) ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${report.regionName} · ${report.category}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI 창업 의사결정 보고서 · ${report.createdAt}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── 섹션 1: 상권 요약 ──
          _buildSection(
            icon: Icons.bar_chart_outlined,
            title: '상권 요약',
            content: report.summary,
            accentColor: const Color(0xFF1E3A5F),
            bgColor: const Color(0xFFE3E9F0),
          ),
          const SizedBox(height: 16),

          // ── 섹션 2: 리스크 요인 (앰버 계열 — ⚠️) ──
          _buildSection(
            icon: Icons.warning_amber_outlined,
            title: '리스크 요인',
            content: report.riskFactors,
            accentColor: const Color(0xFFB86E00),
            bgColor: const Color(0xFFFCECC9),
          ),
          const SizedBox(height: 16),

          // ── 섹션 3: 정책 추천 (그린 계열 — ✅) ──
          _buildSection(
            icon: Icons.lightbulb_outline,
            title: '정책 추천',
            content: report.policyAdvice,
            accentColor: const Color(0xFF2E7D32),
            bgColor: const Color(0xFFE0F0E2),
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
    required Color accentColor,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor, // ⭐ 흰색 → 성격별 연한 배경색
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ⭐ 배경이 흰색이 아니니 그림자도 더 은은하게
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor, // ⭐ bgColor → 흰색으로 (배경과 구분되게)
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
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
      ),
    );
  }
}
