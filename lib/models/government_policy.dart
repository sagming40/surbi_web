class GovernmentPolicy {
  final String id; // 지원사업 고유 ID (pblanc_id)
  final String title; // 사업명
  final String agency; // 실행기관 (메인 표시용, 예: '대구테크노파크')
  final String jrsdInsttNm; // 주관기관 (보조 표시용, 예: '산업통상부')
  final String summary; // 사업 요약 텍스트
  final String startDate; // 신청 시작일 (예: '2026-07-03')
  final String endDate; // 신청 마감일 (예: '2026-08-17')
  final String url; // 신청 페이지 외부 링크

  // 2026-08-18 — category 필드 제거
  // DB팀 확인 결과(3.3 [BE] 1번) government_supports 테이블에 업종·지역
  // 필터 컬럼이 없음. 애초에 존재하지 않는 데이터였음 → 정책은 전체 표시.

  const GovernmentPolicy({
    required this.id,
    required this.title,
    required this.agency,
    required this.jrsdInsttNm,
    required this.summary,
    required this.startDate,
    required this.endDate,
    required this.url,
  });

  factory GovernmentPolicy.fromJson(Map<String, dynamic> json) {
    return GovernmentPolicy(
      id: json['pblanc_id'] as String,
      title: json['title'] as String,
      agency: json['agency'] as String,
      jrsdInsttNm: json['jrsd_instt_nm'] as String,
      summary: json['summary'] as String,
      startDate: json['sprt_start_date'] as String,
      endDate: json['end_date'] as String,
      url: json['support_url'] as String,
    );
  }
}
