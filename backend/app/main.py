import json
from pathlib import Path
from typing import List

from fastapi import FastAPI
from app.models.patient import PatientCase
from app.models.triage import TriageResult
from app.triage_engine import evaluate_patient

app = FastAPI(
    title="TriageFlow AI Backend",
    version="0.1.0",
    description=(
        "Synthetic emergency triage decision-support prototype. "
        "Not for diagnosis or real clinical deployment."
    ),
)

ROOT = Path(__file__).resolve().parent


@app.get("/")
def root() -> dict[str, str]:
    return {
        "service": "TriageFlow AI Backend",
        "status": "ok",
        "safety": "Prototype decision support only. Clinician confirmation required.",
    }


@app.get("/health")
def health() -> dict[str, str]:
    return {
        "status": "ok",
        "service": "triageflow-backend",
        "phase": "00-01-foundation",
    }


@app.get("/api/demo/cases", response_model=List[PatientCase])
def get_demo_cases():
    raw_cases = json.loads((ROOT / "data" / "demo_cases.json").read_text())
    return [PatientCase.model_validate(raw_case) for raw_case in raw_cases]


@app.post("/api/triage/evaluate", response_model=TriageResult)
def evaluate_triage(case: PatientCase):
    return evaluate_patient(case)


@app.get("/api/queue", response_model=List[TriageResult])
def get_queue():
    raw_cases = json.loads((ROOT / "data" / "demo_cases.json").read_text())
    cases = [PatientCase.model_validate(raw_case) for raw_case in raw_cases]
    
    results = [evaluate_patient(case) for case in cases]
    
    # Sort logic (simplified mapping of PriorityLevel to integer for sorting)
    priority_order = {
        "RED": 0,
        "ORANGE": 1,
        "MANUAL_REVIEW": 2,
        "YELLOW": 3,
        "GREEN": 4,
        "BLUE": 5
    }
    
    results.sort(key=lambda x: (priority_order.get(x.priority_level.value, 99), -x.risk_score))
    return results

