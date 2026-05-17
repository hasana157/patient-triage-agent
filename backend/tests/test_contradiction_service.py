"""
Tests for the ContradictionService evidence pipeline.

All test data is synthetic — no real patient data is used.
"""

import pytest
from app.models.patient import PatientCase, Vitals
from app.services.contradiction_service import ContradictionService


@pytest.fixture
def service():
    return ContradictionService()


def _make_case(**overrides) -> PatientCase:
    """Helper to build a PatientCase with sensible defaults."""
    defaults = {
        "case_id": "TEST-001",
        "patient_code": "PT-TEST",
        "age": 40,
        "sex": "male",
        "chief_complaint": "General complaint",
        "symptoms": [],
        "duration_minutes": 30,
        "pain_score": 5,
        "vitals": Vitals(
            heart_rate=80,
            systolic_bp=120,
            diastolic_bp=80,
            respiratory_rate=16,
            spo2=98,
            temperature_c=37.0,
            consciousness="alert",
            recorded_at="2026-05-13T19:00:00+05:00",
        ),
        "vitals_history": [],
        "nurse_note": "No concerns.",
        "arrival_time": "2026-05-13T18:50:00+05:00",
        "current_wait_minutes": 10,
        "source": "synthetic_test",
    }
    defaults.update(overrides)
    return PatientCase(**defaults)


class TestSpo2SymptomMismatch:
    """TEST 3: Patient with spo2=88 and no shortness_of_breath symptom."""

    def test_detects_spo2_mismatch_high_severity(self, service):
        case = _make_case(
            vitals=Vitals(
                heart_rate=90,
                systolic_bp=120,
                diastolic_bp=80,
                respiratory_rate=20,
                spo2=88,
                temperature_c=37.0,
                consciousness="alert",
            ),
            symptoms=["cough"],
            nurse_note="Audible wheeze, patient struggling.",
        )
        contradictions = service.detect_contradictions(case)
        spo2_matches = [c for c in contradictions if c["conflict_type"] == "spo2_symptom_mismatch"]
        assert len(spo2_matches) == 1
        assert spo2_matches[0]["severity"] == "high"


class TestChestPainNoteVsChecklist:
    """TEST 1: Nurse note mentions chest pain but symptom not in checklist."""

    def test_detects_chest_pain_note_vs_checklist(self, service):
        case = _make_case(
            symptoms=["cough"],
            nurse_note="Patient reports severe chest pressure and nausea.",
        )
        contradictions = service.detect_contradictions(case)
        chest_matches = [c for c in contradictions if c["conflict_type"] == "chest_pain_note_vs_checklist"]
        assert len(chest_matches) == 1
        assert chest_matches[0]["severity"] == "high"


class TestPainScoreNoteMismatch:
    """TEST 2: Patient with pain_score=2 and nurse_note='severe pain'."""

    def test_detects_pain_score_note_mismatch(self, service):
        case = _make_case(
            pain_score=2,
            nurse_note="Patient describes severe pain radiating to the back.",
        )
        contradictions = service.detect_contradictions(case)
        pain_matches = [c for c in contradictions if c["conflict_type"] == "pain_score_note_mismatch"]
        assert len(pain_matches) == 1
        assert pain_matches[0]["severity"] == "medium"


class TestVitalsDeterioration:
    """TEST 4: Patient with deteriorating vitals in vitals_history."""

    def test_detects_vitals_deterioration(self, service):
        case = _make_case(
            vitals=Vitals(
                heart_rate=130,
                systolic_bp=85,
                spo2=87,
                respiratory_rate=22,
                diastolic_bp=60,
                temperature_c=37.5,
                consciousness="alert",
                recorded_at="2026-05-13T19:00:00+05:00",
            ),
            vitals_history=[
                Vitals(
                    heart_rate=100,
                    systolic_bp=110,
                    spo2=95,
                    respiratory_rate=18,
                    diastolic_bp=72,
                    temperature_c=37.2,
                    consciousness="alert",
                    recorded_at="2026-05-13T18:30:00+05:00",
                )
            ],
            symptoms=["shortness_of_breath"],
        )
        contradictions = service.detect_contradictions(case)
        det_matches = [c for c in contradictions if c["conflict_type"] == "vitals_deterioration"]
        assert len(det_matches) == 1
        assert det_matches[0]["severity"] == "high"


class TestNoContradictions:
    """TEST 5: Patient with all vitals present and no contradictions."""

    def test_returns_empty_when_no_contradictions(self, service):
        case = _make_case(
            vitals=Vitals(
                heart_rate=80,
                systolic_bp=120,
                diastolic_bp=80,
                respiratory_rate=16,
                spo2=98,
                temperature_c=37.0,
                consciousness="alert",
            ),
            symptoms=["sore_throat"],
            pain_score=5,
            nurse_note="Walking, speaking comfortably, no red flags reported.",
        )
        contradictions = service.detect_contradictions(case)
        assert contradictions == []


class TestConfidencePenalty:
    """Additional tests for the confidence penalty calculator."""

    def test_high_severity_penalty(self, service):
        contradictions = [{"severity": "high"}]
        penalty = service.calculate_confidence_penalty(contradictions, [])
        assert abs(penalty - 0.15) < 0.001

    def test_capped_at_060(self, service):
        # 5 high contradictions = 0.75, but should cap at 0.60
        contradictions = [{"severity": "high"}] * 5
        penalty = service.calculate_confidence_penalty(contradictions, [])
        assert abs(penalty - 0.60) < 0.001

    def test_missing_vitals_block(self, service):
        penalty = service.calculate_confidence_penalty([], ["vitals"])
        assert abs(penalty - 0.25) < 0.001

    def test_missing_individual_fields(self, service):
        penalty = service.calculate_confidence_penalty([], ["heart_rate", "spo2"])
        assert abs(penalty - 0.10) < 0.001
