import json
from pathlib import Path
from fastapi.testclient import TestClient

from app.main import app
from app.models.patient import PatientCase
from app.triage_engine import evaluate_patient

ROOT = Path(__file__).resolve().parents[1]

def test_evaluate_endpoint():
    raw_cases = json.loads((ROOT / "app" / "data" / "demo_cases.json").read_text())
    client = TestClient(app)
    
    for raw_case in raw_cases:
        response = client.post("/api/triage/evaluate", json=raw_case)
        assert response.status_code == 200
        result = response.json()
        assert result["case_id"] == raw_case["case_id"]
        assert "priority_level" in result
        assert "confidence" in result
        assert "risk_score" in result

def test_queue_endpoint():
    client = TestClient(app)
    response = client.get("/api/queue")
    assert response.status_code == 200
    results = response.json()
    assert len(results) >= 5
    
def test_demo_cases_endpoint():
    client = TestClient(app)
    response = client.get("/api/demo/cases")
    assert response.status_code == 200
    cases = response.json()
    assert len(cases) >= 5
    
def test_triage_engine_rules():
    raw_cases = json.loads((ROOT / "app" / "data" / "demo_cases.json").read_text())
    cases = [PatientCase.model_validate(c) for c in raw_cases]
    
    # Evaluate cases and check expected outputs based on deterministic rules
    for case in cases:
        res = evaluate_patient(case)
        assert res.case_id == case.case_id
        
        if case.case_id == "CASE-001":
            # Chest pain, critical vitals expected RED
            assert res.priority_level == "RED"
        elif case.case_id == "CASE-002":
            # SpO2=88 (Critical), resp_rate=30 (Critical), wheezing → RED
            # Contradictions are detected but do not override priority
            assert res.priority_level == "RED"
            assert len(res.contradictions) > 0
        elif case.case_id == "CASE-003":
            # High fever and lethargy in child -> Altered consciousness expected RED
            assert res.priority_level == "RED"
        elif case.case_id == "CASE-004":
            # Forearm injury -> No major red flags, maybe YELLOW
            assert res.priority_level in ["YELLOW", "GREEN", "ORANGE"]
        elif case.case_id == "CASE-005":
            # Mild sore throat -> GREEN
            assert res.priority_level == "GREEN"
        elif case.case_id == "CASE-006":
            # Missing vitals -> MANUAL_REVIEW
            assert res.priority_level == "MANUAL_REVIEW"
            assert "heart_rate" in res.missing_fields
