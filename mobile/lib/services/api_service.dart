import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Central API client for TriageFlow AI.
///
/// Live endpoints: getDemoCases, evaluateTriage, getQueue.
/// Stub endpoints: getActionPlan, executeActions, getOutcome, getLogs.
class ApiService {
  /// Base URL for the backend. Change for production deployment.
 static const String _baseUrl = 'http://127.0.0.1:8000';

  /// Timeout for all HTTP requests.
  static const Duration _timeout = Duration(seconds: 5);

  // ---------------------------------------------------------------------------
  // LIVE ENDPOINTS
  // ---------------------------------------------------------------------------

  /// Fetches all synthetic demo cases from the backend.
  Future<List<PatientCase>> getDemoCases() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/demo/cases'))
          .timeout(_timeout);
      return _handleListResponse(response, PatientCase.fromJson);
    } catch (e) {
      throw _friendlyError('Failed to load demo cases', e);
    }
  }

  /// Sends a patient case to the triage engine for evaluation.
  Future<TriageResult> evaluateTriage(PatientCase patientCase) async {
    try {
      final body = _patientCaseToJson(patientCase);
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/triage/evaluate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleSingleResponse(response, TriageResult.fromJson);
    } catch (e) {
      throw _friendlyError('Triage evaluation failed', e);
    }
  }

  /// Fetches the current priority-sorted queue from the backend.
  /// The backend returns List<TriageResult>, sorted by priority then risk.
  Future<List<TriageResult>> getQueue() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/queue'))
          .timeout(_timeout);
      return _handleListResponse(response, TriageResult.fromJson);
    } catch (e) {
      throw _friendlyError('Failed to load queue', e);
    }
  }

  // ---------------------------------------------------------------------------
  // STUB ENDPOINTS
  // ---------------------------------------------------------------------------

  /// Returns a live action plan from the backend for the given triage result.
  Future<List<ActionStep>> getActionPlan(TriageResult triageResult) async {
    try {
      final body = _triageResultToJson(triageResult);
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/actions/plan'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleListResponse(response, ActionStep.fromJson);
    } catch (e) {
      throw _friendlyError('Action planning failed', e);
    }
  }

  // STUB — replace in Phase 6B when backend endpoint is live
  /// Returns mock execution logs simulating an action chain execution.
  Future<List<ExecutionLog>> executeActions(String caseId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      ExecutionLog(
        logId: 'LOG-001',
        caseId: caseId,
        actionId: 'ACT-$caseId-1',
        timestamp: '2025-01-01T09:00:01.000Z',
        eventType: 'action_executed',
        status: 'success',
        message: 'Recheck vitals — Vitals confirmed',
      ),
      ExecutionLog(
        logId: 'LOG-002',
        caseId: caseId,
        actionId: 'ACT-$caseId-2',
        timestamp: '2025-01-01T09:00:03.000Z',
        eventType: 'action_executed',
        status: 'failed',
        message: 'Alert emergency doctor — API timeout',
      ),
      ExecutionLog(
        logId: 'LOG-003',
        caseId: caseId,
        actionId: 'ACT-$caseId-2',
        timestamp: '2025-01-01T09:00:05.000Z',
        eventType: 'action_retry',
        status: 'retry',
        message: 'Alert emergency doctor (retry) — Retrying...',
        retryCount: 1,
      ),
      ExecutionLog(
        logId: 'LOG-004',
        caseId: caseId,
        actionId: 'ACT-$caseId-2',
        timestamp: '2025-01-01T09:00:07.000Z',
        eventType: 'action_retry',
        status: 'failed',
        message: 'Alert emergency doctor (retry) — Retry failed',
        retryCount: 2,
      ),
      ExecutionLog(
        logId: 'LOG-005',
        caseId: caseId,
        actionId: 'ACT-$caseId-2',
        timestamp: '2025-01-01T09:00:08.000Z',
        eventType: 'fallback_triggered',
        status: 'fallback',
        message: 'Fallback — Added to local urgent queue',
      ),
      ExecutionLog(
        logId: 'LOG-006',
        caseId: caseId,
        actionId: 'ACT-$caseId-3',
        timestamp: '2025-01-01T09:00:10.000Z',
        eventType: 'action_executed',
        status: 'success',
        message: 'Reserve oxygen and ECG — Resources reserved',
      ),
      ExecutionLog(
        logId: 'LOG-007',
        caseId: caseId,
        actionId: 'ACT-$caseId-4',
        timestamp: '2025-01-01T09:00:12.000Z',
        eventType: 'action_executed',
        status: 'success',
        message: 'Schedule reassessment — Timer set for 5 minutes',
      ),
    ];
  }

  // STUB — replace in Phase 6B when backend endpoint is live
  /// Returns mock outcome metrics for a given case.
  Future<OutcomeMetrics> getOutcome(String caseId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return OutcomeMetrics(
      caseId: caseId,
      beforeQueuePosition: 12,
      afterQueuePosition: 2,
      beforeExpectedWaitMinutes: 45,
      afterExpectedWaitMinutes: 8,
      riskScore: 0.82,
      alertsSent: 3,
      resourcesReserved: ['ECG Monitor', 'Oxygen Tank'],
      recoveryStepsUsed: ['fallback_to_urgent_queue'],
      notes: ['Doctor paged via fallback path'],
    );
  }

  // STUB — replace in Phase 6B when backend endpoint is live
  /// Returns mock audit logs for display.
  Future<List<ExecutionLog>> getLogs() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final now = DateTime.now();
    return [
      ExecutionLog(
        logId: 'AUDIT-001',
        caseId: 'CASE-001',
        timestamp: now.subtract(const Duration(hours: 1)).toIso8601String(),
        eventType: 'triage_evaluated',
        status: 'success',
        message: 'Patient CASE-001 triaged as RED — Immediate',
      ),
      ExecutionLog(
        logId: 'AUDIT-002',
        caseId: 'CASE-001',
        timestamp:
            now.subtract(const Duration(minutes: 55)).toIso8601String(),
        eventType: 'action_plan_generated',
        status: 'success',
        message: '5 action steps generated for CASE-001',
      ),
      ExecutionLog(
        logId: 'AUDIT-003',
        caseId: 'CASE-001',
        timestamp:
            now.subtract(const Duration(minutes: 50)).toIso8601String(),
        eventType: 'action_executed',
        status: 'failed',
        message: 'Alert emergency doctor — doctor unavailable',
      ),
      ExecutionLog(
        logId: 'AUDIT-004',
        caseId: 'CASE-001',
        timestamp:
            now.subtract(const Duration(minutes: 48)).toIso8601String(),
        eventType: 'fallback_triggered',
        status: 'success',
        message: 'Fallback — added to local urgent queue',
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // PRIVATE HELPERS
  // ---------------------------------------------------------------------------

  /// Handles a JSON array response and maps each element using [fromJson].
  List<T> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    _checkStatus(response);
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Handles a JSON object response and maps it using [fromJson].
  T _handleSingleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    _checkStatus(response);
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return fromJson(data);
  }

  /// Throws a user-friendly error for non-2xx status codes.
  void _checkStatus(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    if (response.statusCode >= 400 && response.statusCode < 500) {
      throw Exception(
        'Request error (${response.statusCode}): '
        'Please check the submitted data and try again.',
      );
    }
    if (response.statusCode >= 500) {
      throw Exception(
        'Server error (${response.statusCode}): '
        'The backend is temporarily unavailable. Please try again later.',
      );
    }
    throw Exception('Unexpected response: ${response.statusCode}');
  }

  /// Converts a timeout or network error into a readable message.
  Exception _friendlyError(String context, Object error) {
    if (error is Exception) {
      final msg = error.toString();
      if (msg.contains('TimeoutException')) {
        return Exception('$context: Request timed out after 5 seconds.');
      }
      if (msg.contains('SocketException') ||
          msg.contains('Connection refused')) {
        return Exception(
          '$context: Cannot reach the server. '
          'Ensure the backend is running on $_baseUrl.',
        );
      }
      // Already a friendly Exception from _checkStatus
      if (msg.contains('Request error') || msg.contains('Server error')) {
        return error;
      }
    }
    return Exception('$context: An unexpected error occurred.');
  }

  /// Serializes a [PatientCase] to a JSON-compatible map.
  /// Built here because the model class does not have a toJson method.
  Map<String, dynamic> _patientCaseToJson(PatientCase pc) {
    final map = <String, dynamic>{
      'case_id': pc.caseId,
      'patient_code': pc.patientCode,
      'age': pc.age,
      'sex': pc.sex.toLowerCase(),
      'pregnant': pc.pregnant,
      'chief_complaint': pc.chiefComplaint,
      'symptoms': pc.symptoms,
      'duration_minutes': pc.durationMinutes,
      'pain_score': pc.painScore,
      'nurse_note': pc.nurseNote,
      'arrival_time': pc.arrivalTime,
      'current_wait_minutes': pc.currentWaitMinutes,
      'source': pc.source,
      'vitals_history': pc.vitalsHistory.map((v) => {
        'heart_rate': v.heartRate,
        'systolic_bp': v.systolicBp,
        'diastolic_bp': v.diastolicBp,
        'respiratory_rate': v.respiratoryRate,
        'spo2': v.spo2,
        'temperature_c': v.temperatureC,
        'consciousness': v.consciousness,
        'recorded_at': v.recordedAt,
      }).toList(),
    };
    if (pc.vitals != null) {
      map['vitals'] = {
        'heart_rate': pc.vitals!.heartRate,
        'systolic_bp': pc.vitals!.systolicBp,
        'diastolic_bp': pc.vitals!.diastolicBp,
        'respiratory_rate': pc.vitals!.respiratoryRate,
        'spo2': pc.vitals!.spo2,
        'temperature_c': pc.vitals!.temperatureC,
        'consciousness': pc.vitals!.consciousness,
        'recorded_at': pc.vitals!.recordedAt,
      };
    }
    return map;
  }

  /// Serializes a [TriageResult] to a JSON-compatible map.
  Map<String, dynamic> _triageResultToJson(TriageResult tr) {
    return {
      'case_id': tr.caseId,
      'priority_level': tr.priorityLevel,
      'priority_label': tr.priorityLabel,
      'risk_score': tr.riskScore,
      'confidence': tr.confidence,
      'red_flags': tr.redFlags,
      'contradictions': tr.contradictions
          .map((c) => {
                'conflict_type': c.conflictType,
                'severity': c.severity,
                'evidence_a': c.evidenceA,
                'evidence_b': c.evidenceB,
                'resolution_action': c.resolutionAction,
              })
          .toList(),
      'missing_fields': tr.missingFields,
      'reasoning': tr.reasoning,
      'recommended_actions': tr.recommendedActions,
      'safety_disclaimer': tr.safetyDisclaimer,
      'llm_explanation': tr.llmExplanation,
    };
  }

  // ---------------------------------------------------------------------------
  // MOCK DATA CONSTANTS
  // ---------------------------------------------------------------------------

  static const _mockActionTypes = [
    'clinical_reassessment',
    'alert_specialist',
    'reserve_resource',
    'schedule_followup',
    'administer_protocol',
  ];

  static const _mockActionTitles = [
    'Recheck vitals',
    'Alert emergency doctor',
    'Reserve equipment',
    'Schedule reassessment',
    'Initiate triage protocol',
  ];

  static const _mockActionDescriptions = [
    'Repeat vital signs measurement and compare with baseline.',
    'Page the on-call emergency physician for urgent review.',
    'Reserve ECG monitor and oxygen supply for this patient.',
    'Set a 15-minute follow-up reassessment timer.',
    'Begin standard triage protocol per hospital guidelines.',
  ];

  static const _mockTargetRoles = [
    'triage_nurse',
    'emergency_physician',
    'resource_coordinator',
    'charge_nurse',
    'attending_physician',
  ];
}
