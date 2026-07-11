// lib/widgets/step4/policy_card.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:surbi_web/models/government_policy.dart';

class PolicyCard extends StatelessWidget {
  final GovernmentPolicy policy;

  const PolicyCard({super.key, required this.policy});

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.parse(policy.url);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('링크를 열 수 없습니다.')));
    }
  }

  void _onScrapTap(BuildContext context) {
    // TODO: Firestore 스크랩 저장 연동 (Task 2-5)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('스크랩 기능은 준비중이에요.')));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    policy.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () => _onScrapTap(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${policy.agency} · ${policy.jrsdInsttNm}',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${policy.startDate} ~ ${policy.endDate}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              policy.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _openUrl(context),
                child: const Text('자세히 보기 →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
