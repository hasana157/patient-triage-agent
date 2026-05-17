import json
from pathlib import Path
from typing import List, Dict, Any

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from app.models.patient import PatientCase
from app.models.triage import TriageResult
from app.models.action import ActionStep
from app.models.execution import ExecutionLog
from app.models.outcome import OutcomeMetrics
from app.triage_engine import evaluate_patient
from app.planner_service import plan_action_chain
from app.executor_service import execute_action_chain
from app.services.contradiction_service import ContradictionService
from app.services.missing_data_service import MissingDataService

from fastapi.middleware.cors import CORSMiddleware

class ExecuteRequest(BaseModel):
    case_id: str
    actions: List[ActionStep]
    contradictions: List[dict] = []


app = FastAPI(
    title="TriageFlow AI Backend",
    version="0.1.0",
    description=(
        "Synthetic emergency triage decision-support prototype. "
        "Not for diagnosis or real clinical deployment."
    ),
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
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
    priority_order = {
        "RED": 0, "ORANGE": 1, "MANUAL_REVIEW": 2,
        "YELLOW": 3, "GREEN": 4, "BLUE": 5
    }
    results.sort(key=lambda x: (priority_order.get(x.priority_level.value, 99), -x.risk_score))
    return results

@app.post("/api/actions/plan", response_model=List[ActionStep])
def plan_actions(triage_result: TriageResult):
    return plan_action_chain(triage_result)

@app.post("/api/actions/execute")
def execute_actions(request: ExecuteRequest):
    final_actions, logs, outcome = execute_action_chain(
        request.case_id,
        request.actions,
        contradictions=request.contradictions
    )
    return {
        "actions": [a.model_dump(mode="json") for a in final_actions],
        "logs": [l.model_dump(mode="json") for l in logs],
        "outcome": outcome.model_dump(mode="json")
    }

@app.get("/api/outcome")
def get_outcome(case_id: str) -> OutcomeMetrics:
    file_path = ROOT / "logs" / f"outcome_metrics_{case_id}.json"
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Outcome metrics not found for case")
    return OutcomeMetrics.model_validate_json(file_path.read_text())

@app.get("/api/logs", response_model=List[ExecutionLog])
def get_logs(case_id: str):
    file_path = ROOT / "logs" / f"action_execution_log_{case_id}.json"
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Logs not found for case")
    raw_logs = json.loads(file_path.read_text())
    return [ExecutionLog.model_validate(log) for log in raw_logs]

@app.post("/api/contradictions/detect")
def detect_contradictions(case: PatientCase):
    """Run the evidence pipeline independently of triage evaluation."""
    contradiction_svc = ContradictionService()
    missing_data_svc = MissingDataService()

    contradictions = contradiction_svc.detect_contradictions(case)
    stale_warnings = contradiction_svc.detect_stale_vitals(case)
    missing_fields = missing_data_svc.detect_missing_fields(case)
    data_quality = missing_data_svc.assess_data_quality(case)
    confidence_penalty = contradiction_svc.calculate_confidence_penalty(
        contradictions, missing_fields
    )

    return {
        "contradictions": contradictions,
        "stale_warnings": stale_warnings,
        "missing_fields": missing_fields,
        "data_quality": data_quality,
        "confidence_penalty": round(confidence_penalty, 2),
    }

@app.post("/api/demo/run-full")
def run_full_demo(case: PatientCase):
    triage_result = evaluate_patient(case)
    actions = plan_action_chain(triage_result)
    final_actions, logs, outcome = execute_action_chain(case.case_id, actions)
    return {
        "triage_result": triage_result,
        "actions": final_actions,
        "logs": logs,
        "outcome": outcome
    }
