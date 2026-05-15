# Patient Triage Agent / TriageFlow AI

TriageFlow AI is a mobile-first emergency department triage decision-support prototype. It converts synthetic patient intake data into a prototype triage priority, reasoning, missing-data and contradiction warnings, recommended action chains, simulated execution logs, and outcome metrics.

## Safety Note

This project is not a diagnosis tool, not a treatment recommendation system, and not for real clinical deployment. It uses synthetic data only. Every result must be confirmed by licensed clinical staff, and clinicians can override the suggested priority.

## Project Status

- **Phase 00:** Setup and Antigravity safety foundation. **(COMPLETE)**
- **Phase 01:** Requirements, architecture, data contracts. **(COMPLETE)**
- **Phase 02:** Flutter UI Implementation. **(RESET - To be rebuilt by Member 2)**
- **Phase 03:** Backend API & Triage Engine (Deterministic). **(COMPLETE)**

## Architecture

- Flutter mobile app in `mobile/`. **(Phase 2 Skeleton)**
- FastAPI backend in `backend/` for deterministic triage logic and agentic workflow endpoints. **(Phase 3 Complete)**
- JSON/CSV mock data in `backend/app/data/`.
- Safety and Antigravity rules in `.agent/rules/`.
- Architecture and API contract docs in `docs/`.

See [docs/architecture.md](docs/architecture.md) and [docs/api_contract.md](docs/api_contract.md).

## Backend Setup & Testing

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r backend\requirements.txt

# Run server
python -m uvicorn app.main:app --app-dir backend --reload

# Run all tests (Foundation + Triage Engine)
$env:PYTHONPATH='backend'
.\.venv\Scripts\python -m pytest backend
```

## Mobile Handoff (Phase 2)

The Flutter UI has been reset to a minimal state. **Member 2** should implement the production-grade dashboard and triage workflow screens using the models in `mobile/lib/models/`.

## API Status

Implemented in Phase 3:

- `GET /health` — Service health and phase status.
- `GET /api/demo/cases` — List all 6 synthetic demo cases.
- `POST /api/triage/evaluate` — Deterministic evaluation (Risk, Priority, Reasoning).
- `GET /api/queue` — Sorted triage queue.

Planned for future phases:

- `POST /api/actions/plan` — Generate clinical action chains.
- `POST /api/actions/execute` — Simulate execution and recovery.
- `GET /api/outcome` — Before/after metric simulation.
- `GET /api/logs` — Comprehensive audit trails.

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
