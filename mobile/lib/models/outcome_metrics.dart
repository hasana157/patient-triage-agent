class OutcomeMetrics {
  final String caseId;
  final int beforeQueuePosition;
  final int afterQueuePosition;
  final int beforeExpectedWaitMinutes;
  final int afterExpectedWaitMinutes;
  final double riskScore;
  final int alertsSent;
  final List<String> resourcesReserved;
  final List<String> recoveryStepsUsed;
  final List<String> notes;

  const OutcomeMetrics({
    required this.caseId,
    required this.beforeQueuePosition,
    required this.afterQueuePosition,
    required this.beforeExpectedWaitMinutes,
    required this.afterExpectedWaitMinutes,
    required this.riskScore,
    this.alertsSent = 0,
    this.resourcesReserved = const [],
    this.recoveryStepsUsed = const [],
    this.notes = const [],
  });

  factory OutcomeMetrics.fromJson(Map<String, dynamic> json) {
    return OutcomeMetrics(
      caseId: json['case_id'] as String,
      beforeQueuePosition: json['before_queue_position'] as int,
      afterQueuePosition: json['after_queue_position'] as int,
      beforeExpectedWaitMinutes:
          json['before_expected_wait_minutes'] as int,
      afterExpectedWaitMinutes:
          json['after_expected_wait_minutes'] as int,
      riskScore: (json['risk_score'] as num).toDouble(),
      alertsSent: json['alerts_sent'] as int? ?? 0,
      resourcesReserved: (json['resources_reserved'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      recoveryStepsUsed: (json['recovery_steps_used'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
