"""
Contradiction detection service for TriageFlow AI evidence pipeline.

Detects conflicts across structured fields, nurse notes, and vitals
to surface potential data integrity issues. All outputs use uncertainty
language — this is a prototype decision-support tool, not a diagnosis.
"""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Optional

from app.models.patient import PatientCase


class ContradictionService:
    """Detects contradictions and stale vitals in patient case data."""

    def detect_contradictions(self, case: PatientCase) -> list[dict]:
        """
        Detect conflicts across structured fields, nurse note, and vitals.

        Returns a list of contradiction dicts, each with:
          conflict_type, severity, evidence_a, evidence_b, resolution_action
        """
        contradictions: list[dict] = []

        symptoms_lower = [s.lower() for s in case.symptoms]
        nurse_note_lower = (case.nurse_note or "").lower()

        # CHECK 1 — SpO2 vs symptom mismatch
        if case.vitals and case.vitals.spo2 is not None:
            if case.vitals.spo2 < 93 and "shortness_of_breath" not in symptoms_lower:
                # Only flag if nurse note doesn't explicitly negate breathing issues
                if "breathing" not in nurse_note_lower or not any(
                    neg in nurse_note_lower
                    for neg in ["no breathing problem", "denies breathing", "breathing normal"]
                ):
                    contradictions.append({
                        "conflict_type": "spo2_symptom_mismatch",
                        "severity": "high",
                        "evidence_a": f"SpO2 reading is {case.vitals.spo2}% indicating respiratory compromise",
                        "evidence_b": "Shortness of breath not selected in symptom checklist",
                        "resolution_action": "Ask nurse to recheck SpO2 and update symptom checklist",
                    })

        # CHECK 2 — Chest pain in note vs checklist
        chest_keywords = ["chest pain", "chest pressure", "chest tightness"]
        if any(kw in nurse_note_lower for kw in chest_keywords):
            if "chest_pain" not in symptoms_lower:
                contradictions.append({
                    "conflict_type": "chest_pain_note_vs_checklist",
                    "severity": "high",
                    "evidence_a": "Nurse note mentions chest pain or pressure",
                    "evidence_b": "Chest pain not selected in symptom checklist",
                    "resolution_action": "Mark checklist as incomplete — prioritise based on nurse note",
                })

        # CHECK 3 — Pain score vs note severity mismatch
        severity_words = ["severe", "excruciating", "unbearable", "worst", "agony"]
        if case.pain_score is not None and case.pain_score <= 3:
            if any(word in nurse_note_lower for word in severity_words):
                contradictions.append({
                    "conflict_type": "pain_score_note_mismatch",
                    "severity": "medium",
                    "evidence_a": f"Pain score recorded as {case.pain_score}/10 (low)",
                    "evidence_b": "Nurse note describes severe or excruciating pain",
                    "resolution_action": "Ask patient to re-rate pain — reduce confidence score",
                })

        # CHECK 4 — Stale vitals vs latest vitals deterioration
        if case.vitals and case.vitals_history:
            # Find the latest history entry by recorded_at timestamp
            history_with_time = [
                v for v in case.vitals_history if v.recorded_at is not None
            ]
            if history_with_time:
                latest_history = max(history_with_time, key=lambda v: v.recorded_at)

                deterioration_found = False
                old_hr = latest_history.heart_rate
                new_hr = case.vitals.heart_rate
                old_bp = latest_history.systolic_bp
                new_bp = case.vitals.systolic_bp
                old_spo2 = latest_history.spo2
                new_spo2 = case.vitals.spo2

                if old_hr is not None and new_hr is not None:
                    if new_hr - old_hr > 20:
                        deterioration_found = True
                if old_bp is not None and new_bp is not None:
                    if old_bp - new_bp > 20:
                        deterioration_found = True
                if old_spo2 is not None and new_spo2 is not None:
                    if old_spo2 - new_spo2 > 5:
                        deterioration_found = True

                if deterioration_found:
                    contradictions.append({
                        "conflict_type": "vitals_deterioration",
                        "severity": "high",
                        "evidence_a": f"Previous vitals: HR={old_hr} BP={old_bp} SpO2={old_spo2}",
                        "evidence_b": f"Current vitals: HR={new_hr} BP={new_bp} SpO2={new_spo2}",
                        "resolution_action": "Patient is deteriorating — escalate priority",
                    })

        # CHECK 5 — Consciousness vs nurse note conflict
        consciousness_alerts = ["confused", "disoriented", "unresponsive", "drowsy", "lethargic"]
        if case.vitals and case.vitals.consciousness:
            if case.vitals.consciousness.lower() == "alert":
                if any(word in nurse_note_lower for word in consciousness_alerts):
                    contradictions.append({
                        "conflict_type": "consciousness_note_mismatch",
                        "severity": "high",
                        "evidence_a": "Consciousness recorded as Alert",
                        "evidence_b": "Nurse note suggests altered consciousness",
                        "resolution_action": "Recheck consciousness level — do not downgrade priority",
                    })

        return contradictions

    def calculate_confidence_penalty(
        self,
        contradictions: list[dict],
        missing_fields: list[str],
    ) -> float:
        """
        Return a confidence penalty between 0.0 and 0.60.

        Severity weights:
          HIGH   → 0.15
          MEDIUM → 0.08
          LOW    → 0.04

        Missing fields:
          Each missing vital field → 0.05
          Entire vitals block missing → 0.25 additional

        Cap: 0.60 maximum, minimum: 0.0.
        """
        severity_penalties = {"high": 0.15, "medium": 0.08, "low": 0.04}
        penalty = 0.0

        for c in contradictions:
            sev = c.get("severity", "low").lower()
            penalty += severity_penalties.get(sev, 0.04)

        # Missing field penalties
        for field in missing_fields:
            if field == "vitals":
                penalty += 0.25
            else:
                penalty += 0.05

        # Cap at 0.60
        return min(max(penalty, 0.0), 0.60)

    def detect_stale_vitals(self, case: PatientCase) -> list[str]:
        """
        Return warning strings for stale vitals.

        Checks:
          - Current vitals.recorded_at > 30 min before arrival_time
            or > 60 min before now → stale warning
          - vitals_history entries older than 2 hours → additional warnings
        """
        warnings: list[str] = []
        now = datetime.now(timezone.utc)

        if case.vitals and case.vitals.recorded_at is not None:
            recorded = case.vitals.recorded_at
            # Ensure timezone-aware comparison
            if recorded.tzinfo is None:
                recorded = recorded.replace(tzinfo=timezone.utc)

            # Check against arrival_time
            if case.arrival_time is not None:
                arrival = case.arrival_time
                if arrival.tzinfo is None:
                    arrival = arrival.replace(tzinfo=timezone.utc)
                diff_arrival = (arrival - recorded).total_seconds() / 60.0
                if diff_arrival > 30:
                    warnings.append(
                        f"Vitals recorded more than {int(diff_arrival)} minutes before arrival — recheck recommended"
                    )

            # Check against current time
            diff_now = (now - recorded).total_seconds() / 60.0
            if diff_now > 60:
                warnings.append(
                    f"Vitals recorded more than {int(diff_now)} minutes ago — recheck recommended"
                )

        # Check vitals_history for stale entries
        for i, vh in enumerate(case.vitals_history):
            if vh.recorded_at is not None:
                rec = vh.recorded_at
                if rec.tzinfo is None:
                    rec = rec.replace(tzinfo=timezone.utc)
                diff = (now - rec).total_seconds() / 3600.0
                if diff > 2:
                    warnings.append(
                        f"Vitals history entry {i + 1} is more than {int(diff)} hours old — may not reflect current status"
                    )

        return warnings
