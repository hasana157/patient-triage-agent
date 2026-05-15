# TriageFlow AI — Mobile App

Flutter mobile UI for the Patient Triage Agent prototype.

## Safety Note

This app uses synthetic data only. Every triage result must be confirmed by a licensed clinician. This is not a diagnosis or treatment system.

## Setup

```powershell
cd mobile
flutter pub get
flutter run
```

## Screens

| Screen | Route | Description |
|--------|-------|-------------|
| HomeScreen | `/` | Dashboard with demo cases and quick actions |
| PatientIntakeScreen | `/intake` | New patient intake form |
| TriageResultScreen | `/result` | Priority, risk, red flags, reasoning |
| ContradictionScreen | `/contradictions` | Detected contradictions |
| ActionChainScreen | `/actions` | Action timeline, execution logs, outcomes |
| QueueDashboardScreen | `/queue` | Waiting queue and resource status |
| LogsScreen | `/logs` | Execution and audit logs |

## Widgets

- `PriorityBadge` — Color-coded priority level badge
- `SafetyBanner` — Clinical safety disclaimer
- `VitalsInputCard` — Vital signs input form
- `SymptomChipSelector` — Multi-select symptom chips
- `RiskScoreCard` — Circular gauge with confidence bar
- `RedFlagList` — Triggered red-flag rules
- `ContradictionCard` — Contradiction detail with resolution
- `ActionTimeline` — Vertical action chain timeline
- `OutcomeMetricCard` — Before/after queue and resource outcomes
- `ExecutionLogTimeline` — Timestamped execution log timeline

## Architecture

- **Theme**: `lib/theme/app_theme.dart` — Dark theme with 5-level priority color system
- **Models**: `lib/models/` — Dart models matching backend Pydantic contracts
- **Mock Data**: `lib/data/mock_data.dart` — All synthetic data for offline development
- **Screens**: `lib/screens/` — 7 complete screens
- **Widgets**: `lib/widgets/` — 10 reusable components

## Backend Integration (Phase 6)

Replace `MockDataService` calls with HTTP requests to the FastAPI backend. The Dart models use the same field names as the API contract in `docs/api_contract.md`.
