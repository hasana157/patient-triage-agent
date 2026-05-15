# Antigravity Artifact: Phase 00 and 01 Plan

## Project

Patient Triage Agent / TriageFlow AI

## Safety Context

This is a supervised emergency triage decision-support prototype. It is not a diagnosis tool, treatment tool, or real clinical system. Use synthetic data only.

## Phase 00 Checklist

- [x] Create `.gitignore`.
- [x] Create `.env.example`.
- [x] Create README skeleton.
- [x] Create backend folder and requirements.
- [x] Create minimal FastAPI app with `/health`.
- [x] Create mobile folder and Flutter `pubspec.yaml` placeholder.
- [x] Create `.agent/rules/patient-triage-safety.md`.
- [x] Initialize Git repository on `main`.
- [x] Check local Python.
- [x] Check local Git.
- [ ] Check Flutter doctor. Flutter is not installed on `PATH`.
- [x] Confirm backend health route through automated test after dependencies are installed.

## Phase 01 Checklist

- [x] Create `docs/architecture.md`.
- [x] Define five prototype triage levels.
- [x] Define hard red-flag rules.
- [x] Define weighted risk score and confidence score.
- [x] Define backend data models.
- [x] Create synthetic demo cases.
- [x] Create resources data.
- [x] Create queue CSV.
- [x] Create API contract document.
- [x] Add README API contract summary.

## Local Tool Status

- Python: available.
- Git: available.
- Flutter: not found on `PATH`.
- FastAPI: installed in the local `.venv` for verification.
- Git branch: `main`.
- Branch strategy: keep `main` stable, use `phase-02-flutter-ui`, `phase-03-backend-engine`, and similar phase branches for handoffs.
- Git note: the Codex sandbox user sees this folder as dubious ownership, so sandbox Git commands need `git -c safe.directory=D:/hackathon ...`.

## Commands For Backend

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r backend\requirements.txt
python -m uvicorn app.main:app --app-dir backend --reload
```

## Verification Evidence

```powershell
$env:PYTHONPATH='backend'
.\.venv\Scripts\python -m pytest backend
```

Result:

```text
3 passed
```

## Commands For Flutter

```powershell
cd mobile
flutter pub get
flutter run
```

## Handoff Notes

Phase 02 should move into Antigravity for the Flutter UI skeleton. Use the prompt library's Phase 2 Flutter UI prompt and the API contract in `docs/api_contract.md`.
