# TriageFlow AI — Mobile App

Flutter mobile UI for the **Patient Triage Agent** prototype.
Built for the Google Antigravity Hackathon — Phase 02 complete.

---

## ⚠️ Safety Note

> This app uses **synthetic data only**.
> Every triage result must be confirmed by a licensed clinician.
> This is **not** a diagnosis or treatment system.

---

## Quick Start

**Step 1 — Start the backend first**
```powershell
cd ..\backend
python -m uvicorn app.main:app --app-dir backend --reload
```

**Step 2 — Run the Flutter app**
```powershell
cd ..\mobile
flutter pub get
flutter run -d chrome --web-port 5000
```

Open Chrome at `http://localhost:5000`

---

## Screens

| Screen | Description |
|--------|-------------|
| HomeScreen | Landing screen — Run Demo, New Patient, Queue Dashboard |
| PatientIntakeScreen | Full intake form with vitals and symptom selection. Demo pre-fill mode supported. |
| TriageResultScreen | Priority badge, risk score, red flags, reasoning, LLM clinical summary, override button |
| ActionChainScreen | Action timeline with feasibility badges |
| ExecutionSimulationScreen | 7-step simulation — failed → retry → fallback sequence |
| QueueDashboardScreen | Live queue from backend with before/after outcome metrics |
| LogsScreen | TriageResult JSON audit display with Back to Home button |

---

## Widgets

| Widget | Description |
|--------|-------------|
| PriorityBadge | Colour-coded chip — RED / ORANGE / YELLOW / GREEN / BLUE / MANUAL_REVIEW |
| VitalsInputCard | Grouped numeric inputs for HR, BP, RR, SpO2, Temp, Consciousness |
| SymptomChipSelector | Multi-select FilterChip grid — 13 predefined symptoms |
| RiskScoreCard | Linear progress bar coloured by risk level with confidence percentage |
| RedFlagList | Red-tinted warning rows — hidden when empty |
| ContradictionCard | Evidence A vs B with severity badge — hidden when empty (Phase 04) |
| MissingDataBanner | Yellow dismissible banner — hidden when empty (Phase 04) |
| ActionTimeline | Vertical timeline with step number, title, description, status icon |
| OutcomeMetricCard | Before/after comparison with directional arrow |
| ExecutionLogTimeline | Timestamped log list colour-coded by status |

---

## Architecture
```
mobile/lib/
├── main.dart
├── theme/app_theme.dart
├── models/
│   ├── patient_case.dart
│   ├── triage_result.dart
│   ├── action_step.dart
│   ├── execution_log.dart
│   ├── outcome_metrics.dart
│   └── models.dart
├── services/api_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── patient_intake_screen.dart
│   ├── triage_result_screen.dart
│   ├── action_chain_screen.dart
│   ├── execution_simulation_screen.dart
│   ├── queue_dashboard_screen.dart
│   └── logs_screen.dart
└── widgets/
    ├── priority_badge.dart
    ├── vitals_input_card.dart
    ├── symptom_chip_selector.dart
    ├── risk_score_card.dart
    ├── red_flag_list.dart
    ├── contradiction_card.dart
    ├── missing_data_banner.dart
    ├── action_timeline.dart
    ├── outcome_metric_card.dart
    └── execution_log_timeline.dart
```

### Priority Colour System

| Level | Hex | Text Colour |
|-------|-----|-------------|
| RED | #D32F2F | White |
| ORANGE | #E65100 | White |
| YELLOW | #F9A825 | #1A2B3C (dark) |
| GREEN | #2E7D32 | White |
| BLUE | #1565C0 | White |
| MANUAL_REVIEW | #546E7A | White |

---

## API Status

| Method | Endpoint | Status | Notes |
|--------|----------|--------|-------|
| GET | /health | ✅ Live | Health check |
| GET | /api/demo/cases | ✅ Live | Run Demo, intake pre-fill |
| POST | /api/triage/evaluate | ✅ Live | Intake form and Run Demo |
| GET | /api/queue | ✅ Live | Queue Dashboard |
| POST | /api/actions/plan | 🔄 Stub | 404 — not yet implemented on backend |
| POST | /api/actions/execute | 🔄 Stub | Phase 5B — Member 2 next |
| GET | /api/outcome | 🔄 Stub | Phase 5B — Member 2 next |
| GET | /api/logs | 🔄 Stub | Phase 7A — Member 1 |

---

## Demo Flow

Click **Run Demo** on the home screen to auto-navigate:

| Step | Screen | Duration |
|------|--------|----------|
| 1 | Patient Intake — CASE-001 pre-filled | 4 seconds |
| 2 | Triage Result — RED priority, reasoning, LLM summary | 4 seconds |
| 3 | Action Chain — 5 steps with feasibility badges | 3 seconds |
| 4 | Execution Simulation — failed → retry → fallback | 4 seconds |
| 5 | Queue Dashboard — live queue + outcome metrics | 3 seconds |
| 6 | Logs — audit JSON, Back to Home button | Manual |

---

## Phase Status

| Phase | Description | Owner | Status |
|-------|-------------|-------|--------|
| 00 | Setup | Both | ✅ Complete |
| 01 | Architecture | Both | ✅ Complete |
| 02 | Flutter UI | Member 2 | ✅ Complete |
| 03 | Backend + Triage Engine | Member 1 | ✅ Complete |
| 04 | Evidence Pipeline | Member 2 | ✅ Complete |
| 05A | Action Planner + Constraints | Member 1 | ✅ Complete |
| 05B | Executor + Recovery | Member 2 | 🔄 Next |
| 06A | Flutter Integration M1 modules | Member 1 | 🔄 Pending |
| 06B | Flutter Integration M2 modules | Member 2 | 🔄 Pending |
| 07A | Backend QA + Antigravity Artifacts | Member 1 | 🔄 Pending |
| 07B | Flutter QA + Demo Script | Member 2 | 🔄 Pending |
| 08 | Demo Video + Submission | Both | 🔄 Pending |

---

## Known Limitations

- ContradictionCard and MissingDataBanner empty until Phase 04
- Action chain uses mock steps until Phase 06A wires live endpoint
- Execution simulation uses hardcoded logs until Phase 06B
- Queue cards show reasoning[0] as chief complaint
- No Android emulator — verified via flutter analyze and Chrome DevTools

---

## Antigravity Artifacts

Stored in docs/antigravity/:
- phase02_audit_review.md — Full file audit against SRS spec
- phase02_audit_findings.md — Gaps found and fixes applied

flutter analyze — ✅ No issues found
flutter build web --release — ✅ Build successful
