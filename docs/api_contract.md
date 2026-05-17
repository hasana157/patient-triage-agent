# API Contract

This contract is the handoff between the FastAPI backend and Flutter mobile app. Current implementation only exposes the health route; the remaining endpoints are planned for Phase 03 and later.

## General Rules

- JSON only.
- Synthetic data only.
- All clinical output must include safety language.
- All priority results must include reasoning, confidence, and clinician-confirmation requirements.
- Missing critical fields and contradictions must be returned visibly.

## Current Endpoint

### GET `/health`

Response:

```json
{
  "status": "ok",
  "service": "triageflow-backend",
  "phase": "00-01-foundation"
}
```

## Planned Endpoints

### GET `/api/demo/cases`

Returns synthetic cases from `backend/app/data/demo_cases.json`.

Response:

```json
[
  {
    "case_id": "CASE-001",
    "patient_code": "PT-001",
    "age": 58,
    "sex": "female",
    "pregnant": false,
    "chief_complaint": "Chest pain and shortness of breath",
    "symptoms": ["chest_pain", "shortness_of_breath", "sweating"],
    "duration_minutes": 45,
    "pain_score": 9,
    "vitals": {
      "heart_rate": 124,
      "systolic_bp": 88,
      "diastolic_bp": 56,
      "respiratory_rate": 28,
      "spo2": 89,
      "temperature_c": 37.4,
      "consciousness": "alert",
      "recorded_at": "2026-05-13T18:52:00+05:00"
    },
    "vitals_history": [],
    "nurse_note": "Patient appears pale and anxious. Severe chest pressure.",
    "arrival_time": "2026-05-13T18:30:00+05:00",
    "current_wait_minutes": 22,
    "source": "synthetic_demo"
  }
]
```

### GET `/api/queue`

Returns the current synthetic waiting queue from `backend/app/data/queue.csv`.

### POST `/api/triage/evaluate`

Request body: `PatientCase`.

Response body: `TriageResult`.

Example response:

```json
{
  "case_id": "CASE-001",
  "priority_level": "RED",
  "priority_label": "Critical - immediate clinician review",
  "risk_score": 0.94,
  "confidence": 0.88,
  "red_flags": ["low_spo2", "hypotension", "severe_chest_pain"],
  "contradictions": [],
  "missing_fields": [],
  "reasoning": [
    "SpO2 is below prototype safety threshold.",
    "Systolic BP is low.",
    "Severe chest pain appears with sweating and shortness of breath."
  ],
  "llm_explanation": "Patient presents with a critical emergency triage level of RED due to severe hypotension (systolic BP 88 mmHg) and acute hypoxemia (SpO2 89%). The severe chest pain is accompanied by systemic markers (shortness of breath, sweating), indicating a possible acute coronary syndrome. IMMEDIATE CLINICIAN REVIEW IS REQUIRED.",
  "recommended_actions": [
    "validate_critical_vitals",
    "alert_clinician",
    "route_to_resuscitation",
    "reserve_oxygen",
    "schedule_reassessment"
  ],
  "safety_disclaimer": "Prototype decision support only. This is not a diagnosis. A licensed clinician must confirm or override the priority."
}
```

### POST `/api/actions/plan`

Request body:

```json
{
  "case": {},
  "triage_result": {},
  "resources": {}
}
```

Response body:

```json
{
  "case_id": "CASE-001",
  "actions": [
    {
      "action_id": "ACT-001",
      "case_id": "CASE-001",
      "sequence": 1,
      "action_type": "validate_vitals",
      "title": "Recheck critical vitals",
      "description": "Confirm SpO2 and blood pressure before routing.",
      "status": "planned",
      "depends_on": [],
      "target_role": "triage_nurse",
      "deadline_minutes": 1,
      "fallback_action": "manual clinician review",
      "clinician_confirmation_required": true
    }
  ]
}
```

### POST `/api/actions/execute`

Executes a planned action chain in simulation mode and returns execution logs plus updated action statuses. Phase 05 should force one doctor-alert failure, retry once, then use fallback if needed.

### GET `/api/outcome`

Returns the latest `OutcomeMetrics`.

### GET `/api/logs`

Returns audit and simulated execution logs.

### POST `/api/demo/run-full`

Runs a one-click demo:

1. Load critical synthetic case.
2. Evaluate triage.
3. Plan action chain.
4. Simulate alert failure and recovery.
5. Return outcome metrics and logs.

## Error Shape

```json
{
  "error": {
    "code": "validation_error",
    "message": "Vitals are incomplete.",
    "details": {
      "missing_fields": ["vitals.spo2", "vitals.systolic_bp"]
    }
  }
}
```

