# Patient Triage Agent / TriageFlow AI

## Problem
Emergency departments face overcrowding and manual triage pressure, risking delayed identification of critical conditions.

## Solution
A mobile-first, agentic triage decision-support prototype. It turns patient inputs into explainable urgency levels and connected action chains.

## Contributors
- **Member 1**: Backend, triage engine, action planner, constraints, LLM explanation layer, backend QA, Antigravity artifacts
- **Member 2**: Flutter UI, evidence pipeline, execution simulator, recovery, Flutter QA, demo script

## Safety Note
This is not a diagnosis tool and not for real clinical deployment. It is an agentic AI decision-support prototype.

## Architecture
- **Flutter**: Mobile frontend dashboard.
- **FastAPI**: Backend service.
- **Deterministic Triage Engine**: Rules-based urgency identification (no LLMs in the critical path) with an optional LLM-assisted explanation and summarization layer.
- **LLM Explanation Layer (Optional)**: Used only for explanation phrasing, nurse-note summarization, and audit-friendly reasoning generation. It must not make final triage, diagnosis, treatment, escalation, or safety-critical decisions.
- **Agentic Workflow**:
  - Planners generate multi-step action chains.
  - Constraint checkers validate resources.
  - LLM Explanation Layer phrases and summarizes clinical reasoning.
  - Executors act on the environment.
  - Recovery mechanisms self-correct failures (e.g. retry/fallback).

## How to Run

### Backend
```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Mobile
```powershell
cd mobile
flutter pub get
flutter run -d chrome
```

## Demo Flow
1. Patient input (Vitals, Symptoms).
2. Triage engine evaluates risk.
3. Missing data or contradictions trigger safety actions.
4. Planner generates an action chain (e.g., Alert Doctor -> Allocate Bed).
5. Simulator attempts execution, handles failures (e.g., fallback to SMS).
6. Outcome metrics are displayed.

## Limitations
Synthetic data only, simplified rules, not clinically validated. See `docs/limitations.md`.
