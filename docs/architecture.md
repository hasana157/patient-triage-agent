# Patient Triage Agent Architecture

## Purpose

TriageFlow AI is a mobile-first emergency department triage decision-support prototype. It helps staff turn synthetic patient intake, vitals, queue status, resource availability, and nurse notes into an explainable urgency level and action plan.

The system is deliberately conservative. It does not diagnose, prescribe, or replace a nurse or doctor. The safest product line is: the agent highlights acuity, risks, missing data, contradictions, and operational next actions while final responsibility stays with licensed clinical staff.

LLM is used only for explanation phrasing, nurse-note summarization, and audit-friendly reasoning generation. It must not make final triage, diagnosis, treatment, escalation, or safety-critical decisions.

## High-Level System

```text
Flutter Mobile App
  -> FastAPI Backend
      -> Ingestion and validation
      -> Deterministic Triage Engine
      -> Contradiction and missing-data services
      -> Action planner & Constraint checker
      -> Optional LLM Explanation Layer (explanation phrasing, nurse-note summarization, audit reasoning)
      -> Execution simulator and recovery
      -> Outcome metrics
  -> JSON/CSV synthetic data and audit logs
```

## Phase 00/01 Scope

Implemented in the foundation:

- Safe project skeleton.
- Backend health route.
- Pydantic data contracts.
- Synthetic demo cases, resource data, and queue data.
- Safety rules for Antigravity and future agents.
- API contract for backend and Flutter handoff.

Future phases implement the triage engine, contradiction detection, action simulation, recovery, and Flutter screens.

## Priority Levels

| Level | Color | Meaning | Target response |
| --- | --- | --- | --- |
| 1 | Red | Critical, possible immediate life threat | Immediate clinician review |
| 2 | Orange | Emergency, high risk but not full critical | Very urgent review |
| 3 | Yellow | Urgent and stable enough for short wait | Prioritized queue |
| 4 | Green | Semi-urgent, lower risk | Standard queue |
| 5 | Blue | Non-urgent, routine care | Lowest queue priority |

All labels are prototype labels inspired by common 5-level triage systems. They are not official ESI categories and are not clinically validated.

## Hard Red-Flag Rules

Hard rules run before weighted scoring.

| Rule | Condition | Minimum priority | Required action |
| --- | --- | --- | --- |
| RF-001 | Very low SpO2 or severe breathing difficulty | Red | Immediate alert and oxygen resource check |
| RF-002 | Severe chest pain with sweating or shortness of breath | Red or Orange | Doctor alert and ECG resource check |
| RF-003 | Very low systolic BP or shock signs | Red | Move to resuscitation area |
| RF-004 | Unconscious, confused, seizure, or major consciousness change | Red | Immediate clinician alert |
| RF-005 | Severe trauma, bleeding, or burns | Red | Trauma pathway action |
| RF-006 | Pregnancy with bleeding or severe pain | Orange or Red | OB or emergency alert |
| RF-007 | Infant or toddler with high fever and lethargy | Orange or Red | Pediatric urgent review |

## Weighted Risk Score

After hard red flags:

```text
risk_score =
  0.35 * vitals_risk
+ 0.25 * symptom_risk
+ 0.15 * vulnerable_patient_risk
+ 0.10 * pain_duration_risk
+ 0.10 * wait_time_risk
+ 0.05 * resource_pressure_risk
```

Default score mapping:

| Score | Priority |
| --- | --- |
| 0.85 to 1.00 | Red |
| 0.70 to 0.84 | Orange |
| 0.45 to 0.69 | Yellow |
| 0.25 to 0.44 | Green |
| 0.00 to 0.24 | Blue |

## Confidence Score

```text
confidence =
  1.0
- missing_data_penalty
- contradiction_penalty
- stale_data_penalty
```

Low confidence must not hide risk. If the case has critical missing data or contradictions, the response should include manual review and clarification actions.

## Data Contracts

Core backend models live in `backend/app/models/`:

- `PatientCase`
- `Vitals`
- `TriageResult`
- `Contradiction`
- `ActionStep`
- `ExecutionLog`
- `OutcomeMetrics`

Synthetic input data lives in `backend/app/data/`:

- `demo_cases.json`
- `resources.json`
- `queue.csv`

## Agentic Workflow

1. Ingest patient case, queue state, and resources.
2. Validate fields and detect missing or invalid values.
3. Extract risk signals from symptoms, vitals, and nurse note.
4. Detect contradictions and stale evidence.
5. Assign priority with confidence and reasoning.
6. Generate 3 to 5 connected actions.
7. Check resource and time constraints.
8. Call LLM Explanation Layer to phrase and summarize reasoning (with fallback to deterministic reasons).
9. Simulate execution.
10. Recover from failure with retry or fallback.
11. Show before/after operational outcomes.

## Handoff To Flutter

Phase 02 should use the model names and field names in `docs/api_contract.md`. The mobile UI can work against mock data first, then connect to the backend during Phase 06.



## System Flow Diagram (Agentic Workflow)

`mermaid
graph TD
    A[Patient Intake Data] --> B[Triage Engine]
    B -->|Analyze Vitals & Symptoms| C[Missing Data & Contradiction Check]
    C -->|Deterministic Rules| D{Priority Assigned?}
    D -->|Yes| E[Action Planner]
    D -->|Missing/Conflict| F[Manual Review Action]
    F --> E
    E -->|Generate Action Chain| G[Constraint Checker]
    G -->|Validate Resources| H{Feasible?}
    H -->|Yes| I[LLM Explanation Layer]
    H -->|No| J[Generate Fallback]
    J --> I
    I -->|Acuity + Action Chain + Explanation| K[Executor Service]
    K -->|Step 1| L{Action Success?}
    L -->|Yes| M[Next Step...]
    L -->|No| N[Recovery Service]
    N -->|Retry / Fallback| K
    M --> O[Outcome Metrics]
`

