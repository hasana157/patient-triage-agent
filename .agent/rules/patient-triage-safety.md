# Patient Triage Safety Rules

These rules apply to every phase of the Patient Triage Agent project.

## Non-Negotiable Positioning

- This is a supervised clinical decision-support prototype.
- It is not a diagnosis tool.
- It is not a treatment recommendation tool.
- It is not approved for real patient care.
- It must use synthetic demo data only.
- Licensed clinical staff must confirm or override every priority.

## Output Rules

- Use "triage priority", "risk indicators", and "recommended operational actions".
- Do not state or imply confirmed diagnosis.
- Every Red or Orange priority must include immediate clinician confirmation language.
- Every missing critical field must generate a clarification or manual-review action.
- Every contradiction must remain visible to the user and in logs.
- Low confidence must route to manual triage review.

## Data Rules

- Do not store real patient names, phone numbers, addresses, medical record numbers, or other PHI.
- Keep demo data synthetic and clearly marked.
- Do not commit `.env` files or API keys.
- Keep audit logs explainable and free of real PHI.

## Workflow Rules

- Apply hard red-flag rules before weighted scoring.
- Never downgrade critical vital signs because another field appears low risk.
- Use the latest vitals when stale and current vitals conflict.
- Simulated failure recovery must be visible in execution logs.
- Any LLM layer must be optional and explanation-only; deterministic rules own the final priority.

