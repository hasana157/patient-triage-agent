# TriageFlow AI — Mobile App (Member 2 Handoff)

Flutter mobile UI skeleton for the Patient Triage Agent prototype. 

> [!IMPORTANT]
> **Phase 2 Status:** The UI has been reset to a minimal "Phase 0" state to allow Member 2 to implement the production-grade UI from scratch. 
> **Phases 0, 1, & 3 are COMPLETE.** Do not modify the data models or backend logic.

## Setup

```powershell
cd mobile
flutter pub get
flutter run
```

## Available Data Models (Phase 1)

The following models are ready in `lib/models/` and align with the Backend API:
- `PatientCase`: Core patient data and vitals.
- `TriageResult`: Scored priority, risk, and red flags.
- `ActionStep`: Next-step clinical workflows.

## Handoff Tasks for Member 2 (Phase 2)

1. **Rebuild UI:** Implement the hospital-grade dashboard, intake form, and result screens.
2. **Theming:** Use the established design system (dark mode, high contrast).
3. **API Integration:** Connect the UI to the FastAPI backend (Phase 3).

## Architecture Overview

- **Models**: `lib/models/` — Dart models matching backend Pydantic contracts. **(PRESERVED - Phase 1)**
- **Screens**: `lib/screens/` — To be implemented by Member 2. **(RESET - Phase 2)**
- **Widgets**: `lib/widgets/` — To be implemented by Member 2. **(RESET - Phase 2)**

## Safety Note

This app uses synthetic data only. Every triage result must be confirmed by a licensed clinician. This is not a diagnosis or treatment system.

## Backend Integration

The backend is 100% functional (Phase 3). You can view the API contract in `docs/api_contract.md`. The Dart models are already mapped to match these JSON responses.
