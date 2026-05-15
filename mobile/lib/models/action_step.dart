class ActionStep {
  final String actionId;
  final String caseId;
  final int sequence;
  final String actionType;
  final String title;
  final String description;
  final String status;
  final List<String> dependsOn;
  final String? targetRole;
  final int? deadlineMinutes;
  final String? fallbackAction;
  final bool clinicianConfirmationRequired;

  const ActionStep({
    required this.actionId,
    required this.caseId,
    required this.sequence,
    required this.actionType,
    required this.title,
    required this.description,
    this.status = 'planned',
    this.dependsOn = const [],
    this.targetRole,
    this.deadlineMinutes,
    this.fallbackAction,
    this.clinicianConfirmationRequired = true,
  });

  factory ActionStep.fromJson(Map<String, dynamic> json) {
    return ActionStep(
      actionId: json['action_id'] as String,
      caseId: json['case_id'] as String,
      sequence: json['sequence'] as int,
      actionType: json['action_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String? ?? 'planned',
      dependsOn: (json['depends_on'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      targetRole: json['target_role'] as String?,
      deadlineMinutes: json['deadline_minutes'] as int?,
      fallbackAction: json['fallback_action'] as String?,
      clinicianConfirmationRequired:
          json['clinician_confirmation_required'] as bool? ?? true,
    );
  }
}
