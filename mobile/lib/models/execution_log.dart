class ExecutionLog {
  final String logId;
  final String caseId;
  final String? actionId;
  final String timestamp;
  final String eventType;
  final String status;
  final String message;
  final int retryCount;
  final Map<String, dynamic> evidence;

  const ExecutionLog({
    required this.logId,
    required this.caseId,
    this.actionId,
    required this.timestamp,
    required this.eventType,
    required this.status,
    required this.message,
    this.retryCount = 0,
    this.evidence = const {},
  });

  factory ExecutionLog.fromJson(Map<String, dynamic> json) {
    return ExecutionLog(
      logId: json['log_id'] as String,
      caseId: json['case_id'] as String,
      actionId: json['action_id'] as String?,
      timestamp: json['timestamp'] as String,
      eventType: json['event_type'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      retryCount: json['retry_count'] as int? ?? 0,
      evidence: json['evidence'] as Map<String, dynamic>? ?? {},
    );
  }
}
