# Limitations and Safety Disclaimers

## Medical Safety Disclaimer
**TriageFlow AI is a decision-support prototype.** 
It does not diagnose disease, prescribe treatment, or replace licensed clinical judgment. The priority levels and suggested action chains are generated for demonstration and academic purposes only.

## Current System Limitations

1. **No Clinical Validation**: The hard red-flag rules (e.g., SpO2 < 90 = RED) and weighted scoring formulas were designed for structural demonstration and have not been peer-reviewed or tested in a clinical trial.
2. **Synthetic Data Only**: The system is hardcoded to accept the synthetic variables provided in the `demo_cases.json`. Real-world EHR integrations (HL7/FHIR) are not implemented.
3. **Deterministic Constraints**: The planner acts intelligently, but it is bounded by the static `resources.json` rules rather than live hospital sensors.
4. **No True Generative AI for Decisions**: To guarantee safety, LLMs are intentionally omitted from the core triage logic. The "agentic" behavior comes from programmatic planning, constraint solving, and recovery loops rather than generative text.
5. **Mock Execution**: The `executor_service` only simulates actions (e.g., it writes to an audit log instead of actually paging a doctor).

## Future Work
- Integration with FHIR standards for live patient data.
- Live telemetry from hospital beds and ECG machines to feed the constraint service dynamically.
- Formal clinical trials to tune the risk weights.
