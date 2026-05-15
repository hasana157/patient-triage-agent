# Patient Triage Agent / TriageFlow AI

TriageFlow AI is a mobile-first emergency department triage decision-support prototype. It converts synthetic patient intake data into a prototype triage priority, reasoning, missing-data and contradiction warnings, recommended action chains, simulated execution logs, and outcome metrics.

## Safety Note

This project is not a diagnosis tool, not a treatment recommendation system, and not for real clinical deployment. It uses synthetic data only. Every result must be confirmed by licensed clinical staff, and clinicians can override the suggested priority.

## Current Phase

- Phase 00: Setup and Antigravity safety foundation.
- Phase 01: Requirements, architecture, data contracts, and synthetic data.

## Architecture

- Flutter mobile app in `mobile/` for the nurse/doctor workflow.
- FastAPI backend in `backend/` for deterministic triage logic and agentic workflow endpoints.
- JSON/CSV mock data in `backend/app/data/`.
- Safety and Antigravity rules in `.agent/rules/`.
- Architecture and API contract docs in `docs/`.

See [docs/architecture.md](docs/architecture.md) and [docs/api_contract.md](docs/api_contract.md).

## Backend Setup

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r backend\requirements.txt
python -m uvicorn app.main:app --app-dir backend --reload
```

Health check:

```powershell
Invoke-RestMethod http://127.0.0.1:8000/health
```

Run foundation tests:

```powershell
$env:PYTHONPATH='backend'
.\.venv\Scripts\python -m pytest backend
```

## Mobile Setup

Flutter was not found on this workstation during Phase 00. After Flutter is installed and available on `PATH`, use:

```powershell
cd mobile
flutter pub get
flutter run
```

Phase 02 should create the Flutter screens using the contract and synthetic mock data already defined here.

## API Contract Summary

Implemented now:

- `GET /health` returns backend service status.

Planned for Phase 03 and later:

- `GET /api/demo/cases`
- `GET /api/queue`
- `POST /api/triage/evaluate`
- `POST /api/actions/plan`
- `POST /api/actions/execute`
- `GET /api/outcome`
- `GET /api/logs`
- `POST /api/demo/run-full`

The canonical request and response examples are documented in [docs/api_contract.md](docs/api_contract.md).

## Demo Flow

1. Select or enter a synthetic patient case.
2. Evaluate triage priority with transparent reasoning.
3. Surface missing data and contradictions.
4. Generate 3 to 5 connected operational actions.
5. Simulate execution, including alert failure and recovery.
6. Show before/after queue and resource outcomes.

## Limitations

- Simplified, ESI-inspired prototype rules only.
- No clinical validation.
- No real patient data.
- No EHR integration.
- Deterministic rules should decide priority; any LLM layer must be explanation-only.
