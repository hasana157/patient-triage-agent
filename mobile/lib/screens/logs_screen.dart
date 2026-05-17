import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Displays a TriageResult as pretty-printed JSON.
/// If no result is supplied, shows a hardcoded mock TriageResult.
class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key, this.result});

  final TriageResult? result;

  Map<String, dynamic> _triageResultToMap(TriageResult triageResult) {
    return {
      'case_id': triageResult.caseId,
      'priority_level': triageResult.priorityLevel,
      'priority_label': triageResult.priorityLabel,
      'risk_score': triageResult.riskScore,
      'confidence': triageResult.confidence,
      'red_flags': triageResult.redFlags,
      'contradictions': triageResult.contradictions
          .map((c) => {
                'conflict_type': c.conflictType,
                'severity': c.severity,
                'evidence_a': c.evidenceA,
                'evidence_b': c.evidenceB,
                'resolution_action': c.resolutionAction,
              })
          .toList(),
      'missing_fields': triageResult.missingFields,
      'reasoning': triageResult.reasoning,
      'recommended_actions': triageResult.recommendedActions,
    };
  }

  Map<String, dynamic> get _mockResultJson {
    return {
      'case_id': 'CASE-001',
      'priority_level': 'RED',
      'priority_label': 'Immediate',
      'risk_score': 0.92,
      'confidence': 0.88,
      'red_flags': ['chest pain', 'hypotension'],
      'contradictions': [
        {
          'conflict_type': 'vitals_vs_pain',
          'severity': 'medium',
          'evidence_a': 'Normal blood pressure',
          'evidence_b': 'Severe chest pain reported',
          'resolution_action': 'Recheck vitals and consult senior clinician',
        }
      ],
      'missing_fields': ['consciousness'],
      'reasoning': [
        'High risk due to chest pain and hypotension.',
        'Model confidence is strong at 88%.'
      ],
      'recommended_actions': [
        'Alert emergency doctor',
        'Reserve oxygen and ECG',
        'Schedule reassessment'
      ],
    };
  }

  String _prettyJson(Map<String, dynamic> map) {
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  @override
  Widget build(BuildContext context) {
    final displayMap = result != null
        ? _triageResultToMap(result!)
        : _mockResultJson;
    final jsonText = _prettyJson(displayMap);

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Logs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTheme.buildSafetyBanner(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonText,
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to Home',
                    style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryAction,
                  side: const BorderSide(color: AppTheme.primaryAction),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Live audit logs come from GET /api/logs in Phase 7A.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
