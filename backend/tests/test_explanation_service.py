import pytest
from app.models.triage import TriageResult, PriorityLevel
from app.models.patient import PatientCase, Vitals
from app.triage_engine import evaluate_patient
from app.explanation_service import generate_llm_explanation

def test_generate_llm_explanation_basic():
    triage_result = TriageResult(
        case_id="CASE-TEST-EXP1",
        priority_level=PriorityLevel.RED,
        priority_label="Critical",
        risk_score=0.95,
        confidence=1.0,
        red_flags=["low_spo2", "hypotension"],
        reasoning=["SpO2 is low", "BP is low"],
        recommended_actions=["alert_doctor"]
    )
    
    explanation = generate_llm_explanation(triage_result, nurse_note="Patient is pale and anxious.")
    
    assert "RED" in explanation
    assert "low_spo2" in explanation
    assert "hypotension" in explanation
    assert "pale and anxious" in explanation
    # Mandated safety disclaimer text
    assert "CLINICIAN CONFIRMATION IS MANDATORY" in explanation

def test_explanation_layer_is_strictly_explanation_only():
    triage_result = TriageResult(
        case_id="CASE-TEST-EXP2",
        priority_level=PriorityLevel.ORANGE,
        priority_label="Emergency",
        risk_score=0.75,
        confidence=0.90,
        red_flags=["chest_pain"],
        reasoning=["Chest pain reported"],
        recommended_actions=["alert_doctor", "setup_ecg"]
    )
    
    # Store original values to verify explanation layer doesn't modify core triage results
    orig_priority = triage_result.priority_level
    orig_risk_score = triage_result.risk_score
    orig_red_flags = list(triage_result.red_flags)
    orig_contradictions = list(triage_result.contradictions)
    orig_recommended_actions = list(triage_result.recommended_actions)
    
    explanation = generate_llm_explanation(triage_result, nurse_note="Patient note description")
    
    assert triage_result.priority_level == orig_priority
    assert triage_result.risk_score == orig_risk_score
    assert triage_result.red_flags == orig_red_flags
    assert triage_result.contradictions == orig_contradictions
    assert triage_result.recommended_actions == orig_recommended_actions

def test_explanation_fallback_behavior():
    triage_result = TriageResult(
        case_id="CASE-TEST-EXP3",
        priority_level=PriorityLevel.YELLOW,
        priority_label="Urgent",
        risk_score=0.50,
        confidence=1.0,
        red_flags=[],
        reasoning=["Wait time > 60 min"],
        recommended_actions=[]
    )
    
    explanation = generate_llm_explanation(triage_result, simulate_llm_failure=True)
    
    assert "FALLBACK" in explanation
    assert "Wait time > 60 min" in explanation

def test_core_triage_unaffected_by_llm_layer():
    case = PatientCase(
        case_id="CASE-TEST-EXP4",
        patient_code="PT-EXP4",
        age=45,
        chief_complaint="Chest pain",
        symptoms=["chest_pain"],
        vitals=Vitals(
            heart_rate=90,
            systolic_bp=120,
            diastolic_bp=80,
            respiratory_rate=16,
            spo2=98,
            temperature_c=36.8,
            consciousness="alert"
        ),
        nurse_note="Patient stable but complains of mild chest pressure."
    )
    
    result = evaluate_patient(case)
    
    assert result.priority_level == PriorityLevel.RED
    assert result.llm_explanation is not None
    assert "RED" in result.llm_explanation
    assert "chest pressure" in result.llm_explanation
