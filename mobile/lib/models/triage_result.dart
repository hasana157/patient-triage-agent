class Contradiction {
  final String conflictType;
  final String severity;
  final String evidenceA;
  final String evidenceB;
  final String resolutionAction;

  const Contradiction({
    required this.conflictType,
    required this.severity,
    required this.evidenceA,
    required this.evidenceB,
    required this.resolutionAction,
  });

  factory Contradiction.fromJson(Map<String, dynamic> json) {
    return Contradiction(
      conflictType: json['conflict_type'] as String,
      severity: json['severity'] as String,
      evidenceA: json['evidence_a'] as String,
      evidenceB: json['evidence_b'] as String,
      resolutionAction: json['resolution_action'] as String,
    );
  }
}

class TriageResult {
  final String caseId;
  final String priorityLevel;
  final String priorityLabel;
  final double riskScore;
  final double confidence;
  final List<String> redFlags;
  final List<Contradiction> contradictions;
  final List<String> missingFields;
  final List<String> reasoning;
  final List<String> recommendedActions;
  final String safetyDisclaimer;
  final String? llmExplanation;

  const TriageResult({
    required this.caseId,
    required this.priorityLevel,
    required this.priorityLabel,
    required this.riskScore,
    required this.confidence,
    this.redFlags = const [],
    this.contradictions = const [],
    this.missingFields = const [],
    this.reasoning = const [],
    this.recommendedActions = const [],
    this.safetyDisclaimer =
        'Prototype decision support only. This is not a diagnosis. '
            'A licensed clinician must confirm or override the priority.',
    this.llmExplanation,
  });

  factory TriageResult.fromJson(Map<String, dynamic> json) {
    return TriageResult(
      caseId: json['case_id'] as String,
      priorityLevel: json['priority_level'] as String,
      priorityLabel: json['priority_label'] as String,
      riskScore: (json['risk_score'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      redFlags: (json['red_flags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      contradictions: (json['contradictions'] as List<dynamic>?)
              ?.map(
                  (e) => Contradiction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      missingFields: (json['missing_fields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      reasoning: (json['reasoning'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      recommendedActions: (json['recommended_actions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      safetyDisclaimer: json['safety_disclaimer'] as String? ??
          'Prototype decision support only. This is not a diagnosis. '
              'A licensed clinician must confirm or override the priority.',
      llmExplanation: json['llm_explanation'] as String?,
    );
  }
}
