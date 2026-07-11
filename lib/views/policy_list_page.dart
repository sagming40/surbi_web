// lib/views/policy_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/providers/score_provider.dart';
import 'package:surbi_web/widgets/common/surbi_empty.dart';
import 'package:surbi_web/widgets/step4/policy_card.dart';

class PolicyListPage extends ConsumerWidget {
  const PolicyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policies = ref.watch(policiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('정부 지원사업')),
      body: policies.isEmpty
          ? const SurbiEmpty(message: '해당 조건에 맞는 지원사업이 없습니다.')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: policies.length,
              itemBuilder: (context, index) {
                final policy = policies[index];
                return PolicyCard(policy: policy);
              },
            ),
    );
  }
}
