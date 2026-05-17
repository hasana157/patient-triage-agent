import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/priority_badge.dart';
import '../widgets/risk_score_card.dart';
import '../widgets/red_flag_list.dart';
import '../widgets/missing_data_banner.dart';
import '../widgets/contradiction_card.dart';
import 'action_chain_screen.dart';

/// Displays the full triage evaluation result.
class TriageResultScreen extends StatelessWidget {
  const TriageResultScreen({
    super.key,
    required this.result,
    required this.patientCode,
    this.isDemo = false,
  });

  final TriageResult result;
  final String patientCode;
  final bool isDemo;

  void _showOverrideSheet(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Override Priority',
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Current: ${result.priorityLevel}',
                style: const TextStyle(color: AppTheme.secondaryText)),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.primaryText),
              decoration: const InputDecoration(
                hintText: 'Reason for override…',
                labelText: 'Override Reason',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final reason = reasonCtrl.text.trim();
                  if (reason.isEmpty) return;
                  debugPrint(
                    '[OVERRIDE] Case: ${result.caseId} | '
                    'From: ${result.priorityLevel} | '
                    'Reason: $reason',
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Override logged (console).')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warning,
                  foregroundColor: AppTheme.primaryText,
                ),
                child: const Text('Confirm Override'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Triage Result — $patientCode'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Safety banner
          AppTheme.buildSafetyBanner(),
          const SizedBox(height: 20),

          // Priority badge (large) + label
          Center(child: PriorityBadge(level: result.priorityLevel, large: true)),
          const SizedBox(height: 10),
          Center(
            child: Text(
              AppTheme.priorityDescription(result.priorityLevel),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primaryText),
            ),
          ),
          const SizedBox(height: 20),

          // Risk score
          RiskScoreCard(
            riskScore: result.riskScore,
            confidence: result.confidence,
          ),
          const SizedBox(height: 12),

          // Red flags
          RedFlagList(flags: result.redFlags),
          if (result.redFlags.isNotEmpty) const SizedBox(height: 12),

          // Reasoning
          if (result.reasoning.isNotEmpty) ...[
            Container(
              decoration: AppTheme.cardDecoration(),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_outlined, size: 20, color: AppTheme.primaryText),
                      const SizedBox(width: 8),
                      Text('Reasoning',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...result.reasoning.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  ',
                                style: TextStyle(color: AppTheme.secondaryText)),
                            Expanded(
                                child: Text(r,
                                    style: const TextStyle(fontSize: 14, color: AppTheme.bodyText))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Missing data
          MissingDataBanner(fields: result.missingFields),
          if (result.missingFields.isNotEmpty) const SizedBox(height: 12),

          // Contradictions
          ContradictionCard(contradictions: result.contradictions),
          if (result.contradictions.isNotEmpty) const SizedBox(height: 12),

          // LLM Clinical Summary — shown only when backend provides it
          if (result.llmExplanation != null &&
              result.llmExplanation!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD1D9E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology_outlined,
                          size: 16, color: Color(0xFF1565C0)),
                      SizedBox(width: 6),
                      Text('Clinical Summary',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A2B3C))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.llmExplanation!,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A5568),
                        height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Generated by explanation layer — '
                    'not used for priority decisions.',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF718096),
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActionChainScreen(
                    result: result,
                    patientCode: patientCode,
                    isDemo: isDemo,
                  ),
                ),
              ),
              icon: const Icon(Icons.account_tree_outlined),
              label: const Text('View Action Plan',
                  style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAction,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showOverrideSheet(context),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Override Priority',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
