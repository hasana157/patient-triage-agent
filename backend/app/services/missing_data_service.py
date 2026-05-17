"""
Missing data detection and data quality scoring for TriageFlow AI.

Identifies missing or null fields in patient cases and produces a
completeness score with recommendations. All outputs are advisory —
clinical confirmation is always required.
"""

from __future__ import annotations

from app.models.patient import PatientCase


class MissingDataService:
    """Detects missing fields and assesses data quality for triage input."""

    # Vital field names to check when vitals block exists
    _VITAL_FIELDS = [
        "heart_rate",
        "systolic_bp",
        "diastolic_bp",
        "respiratory_rate",
        "spo2",
        "temperature_c",
        "consciousness",
    ]

    def detect_missing_fields(self, case: PatientCase) -> list[str]:
        """
        Return a list of field names that are missing or null.

        Checks:
          - vitals (entire block)
          - Individual vital fields if vitals exists
          - pain_score
          - duration_minutes
          - nurse_note (warn if empty or None)

        Does NOT mark symptoms or pregnant as missing.
        """
        missing: list[str] = []

        if case.vitals is None:
            missing.append("vitals")
        else:
            for field_name in self._VITAL_FIELDS:
                if getattr(case.vitals, field_name, None) is None:
                    missing.append(field_name)

        if case.pain_score is None:
            missing.append("pain_score")

        if case.duration_minutes is None:
            missing.append("duration_minutes")

        if not case.nurse_note or case.nurse_note.strip() == "":
            missing.append("nurse_note")

        return missing

    def assess_data_quality(self, case: PatientCase) -> dict:
        """
        Return a quality assessment dict:
          {
            "completeness_score": float (0.0–1.0),
            "missing_fields": list[str],
            "missing_critical": bool,
            "recommendation": "proceed" | "recheck" | "manual_review"
          }

        Scoring deductions:
          - Entire vitals block missing: −0.30
          - Per missing vital field: −0.05
          - pain_score missing: −0.10
          - duration_minutes missing: −0.05
          - nurse_note empty: −0.03
        """
        missing_fields = self.detect_missing_fields(case)
        score = 1.0

        if "vitals" in missing_fields:
            score -= 0.30
        else:
            for field_name in self._VITAL_FIELDS:
                if field_name in missing_fields:
                    score -= 0.05

        if "pain_score" in missing_fields:
            score -= 0.10

        if "duration_minutes" in missing_fields:
            score -= 0.05

        if "nurse_note" in missing_fields:
            score -= 0.03

        # Clamp to [0.0, 1.0]
        score = max(0.0, min(1.0, score))

        # Determine if critical data is missing
        missing_critical = "vitals" in missing_fields or len(missing_fields) >= 3

        # Recommendation logic
        if score >= 0.85:
            recommendation = "proceed"
        elif score >= 0.60:
            recommendation = "recheck"
        else:
            recommendation = "manual_review"

        return {
            "completeness_score": round(score, 2),
            "missing_fields": missing_fields,
            "missing_critical": missing_critical,
            "recommendation": recommendation,
        }
