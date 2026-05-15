import json
from pathlib import Path

from fastapi.testclient import TestClient

from app.main import app
from app.models import PatientCase


ROOT = Path(__file__).resolve().parents[1]


def test_health_route() -> None:
    response = TestClient(app).get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"
    assert response.json()["phase"] == "00-01-foundation"


def test_demo_cases_match_patient_contract() -> None:
    raw_cases = json.loads((ROOT / "app" / "data" / "demo_cases.json").read_text())

    cases = [PatientCase.model_validate(raw_case) for raw_case in raw_cases]

    assert len(cases) >= 5
    assert all(case.source == "synthetic_demo" for case in cases)
    assert {case.case_id for case in cases}


def test_resources_are_synthetic() -> None:
    resources = json.loads((ROOT / "app" / "data" / "resources.json").read_text())

    assert resources["data_mode"] == "synthetic_demo"
    assert resources["constraints"]["force_first_doctor_alert_failure"] is True

