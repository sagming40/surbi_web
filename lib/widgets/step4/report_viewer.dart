// lib/widgets/step4/report_viewer.dart

import 'package:flutter/material.dart';
import 'package:surbi_web/models/report.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/widgets/common/surbi_card.dart';

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
          // ⚠️ 여기만 SurbiCard를 안 쓴다. 이건 카드가 아니라 **배너**다 —
          //    바탕이 진한 accent라 그림자를 깔면 지저분해지고, 모서리도
          //    카드(20)보다 작은 chip(16)이 어울린다.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SurbiColors.accent,
              borderRadius: BorderRadius.circular(SurbiRadius.chip),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${report.regionName} · ${report.category}',
                  style: const TextStyle(
                    fontSize: SurbiText.title,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI 창업 의사결정 보고서 · ${report.createdAt}',
                  style: TextStyle(
                    fontSize: SurbiText.label,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // SurbiCard가 위아래로 margin 8을 갖고 있어 12 + 8 = 20이 된다
          const SizedBox(height: 12),

          // ── 섹션 1: 상권 요약 ──
          _buildSection(
            icon: Icons.bar_chart_outlined,
            title: '상권 요약',
            content: report.summary,
            accentColor: SurbiColors.accent,
            bgColor: SurbiColors.accentTint,
          ),

          // ── 섹션 2: 리스크 요인 (앰버 계열 — ⚠️) ──
          _buildSection(
            icon: Icons.warning_amber_outlined,
            title: '리스크 요인',
            content: report.riskFactors,
            accentColor: SurbiColors.warn,
            bgColor: SurbiColors.warnTint,
          ),

          // ── 섹션 3: 정책 추천 (그린 계열 — ✅) ──
          _buildSection(
            icon: Icons.lightbulb_outline,
            title: '정책 추천',
            content: report.policyAdvice,
            accentColor: SurbiColors.good,
            bgColor: SurbiColors.goodTint,
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
    // 손으로 그리던 카드를 SurbiCard로 교체했다 (2026-08-26).
    // 예전 주석은 "배경이 흰색이 아니니 그림자도 더 진하게"라며 알파를 0.1로
    // 뒀는데, 기준(SurbiShadow.card)의 두 배였다. **주석과 값이 반대**였던 셈.
    // 카드 사이 간격은 SurbiCard의 margin(세로 8+8=16)이 만든다 → SizedBox 제거.
    return SurbiCard(
      backgroundColor: bgColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  // 주석은 "흰색으로 (배경과 구분되게)"인데 값은 bgColor라
                  // 카드 배경과 같은 색 = 원이 안 보이는 상태였다 → 주석대로 고침
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: SurbiText.subtitle,
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
              fontSize: SurbiText.body,
              height: 1.6,
              color: SurbiColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
