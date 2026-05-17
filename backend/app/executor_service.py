import json
import uuid
from pathlib import Path

from app.models.action import ActionStep, ActionStatus
from app.models.execution import ExecutionLog, ExecutionStatus
from app.models.outcome import OutcomeMetrics
from app.constraint_service import load_resources, check_resources_for_action
from app.recovery_service import handle_failure

ROOT = Path(__file__).resolve().parent

def execute_action_chain(case_id: str, actions: list[ActionStep], initial_wait: int = 120, force_fail_first_alert: bool = True, contradictions: list[dict] = None):
    """
    AGENTIC AI MODULE: Execution Simulator
    
    This function simulates the agent acting upon the real world. It goes through the 
    planned action chain step-by-step. It implements:
    - State Transitions: Tracking actions from STARTED -> RUNNING -> SUCCEEDED/FAILED.
    - Simulated Failure: Random or forced failures (like an API timeout) to prove the agent can handle real-world unreliability.
    - Failure Recovery: Integrating with the recovery_service to retry or trigger fallback mechanisms.
    - Audit Logging: Generating a complete, step-by-step operational trace of what the agent did.
    """
    resources = load_resources()
    logs = []
    
    from app.services.contradiction_service import ContradictionService
    contradiction_service = ContradictionService()
    
    if contradictions is not None and any(c.get("severity") == "high" for c in contradictions):
        logs.append(ExecutionLog(
            log_id=str(uuid.uuid4()), case_id=case_id, action_id="system",
            event_type="contradiction_warning", status=ExecutionStatus.INFO,
            message="High severity contradictions detected — execution proceeding with elevated caution. Clinician verification required."
        ))

    # Check if force fail is requested
    force_fail = force_fail_first_alert and resources.get("constraints", {}).get("force_first_doctor_alert_failure", True)
    
    if contradictions is not None and any(c.get("type") == "vitals_deterioration" for c in contradictions):
        force_fail = True
        logs.append(ExecutionLog(
            log_id=str(uuid.uuid4()), case_id=case_id, action_id="system",
            event_type="contradiction_warning", status=ExecutionStatus.INFO,
            message="Vitals deterioration detected — forcing alert verification step."
        ))
    
    first_alert_failed = False
    alerts_sent = 0
    resources_reserved = []
    recovery_steps = []
    
    for action in sorted(actions, key=lambda a: a.sequence):
        logs.append(ExecutionLog(
            log_id=str(uuid.uuid4()), case_id=case_id, action_id=action.action_id,
            event_type="action_started", status=ExecutionStatus.INFO,
            message=f"Starting action: {action.title}"
        ))
        
        if not check_resources_for_action(action.action_type, resources):
            action.status = ActionStatus.BLOCKED
            logs.append(ExecutionLog(
                log_id=str(uuid.uuid4()), case_id=case_id, action_id=action.action_id,
                event_type="action_blocked", status=ExecutionStatus.FAILED,
                message=f"Resources unavailable for {action.action_type}"
            ))
            continue
            
        action.status = ActionStatus.RUNNING
        
        attempt = 0
        success = False
        max_retries = resources.get("constraints", {}).get("max_retry_attempts", 1)
        
        while attempt <= max_retries and not success:
            if action.action_type == "alert_doctor" and force_fail:
                # Force failure on all attempts to trigger fallback
                success = False
            else:
                success = True # simulate success
                
            if success:
                action.status = ActionStatus.SUCCEEDED
                logs.append(ExecutionLog(
                    log_id=str(uuid.uuid4()), case_id=case_id, action_id=action.action_id,
                    event_type="action_completed", status=ExecutionStatus.SUCCEEDED,
                    message=f"Action '{action.title}' completed successfully.",
                    retry_count=attempt
                ))
                if "alert" in action.action_type:
                    alerts_sent += 1
                if "allocate" in action.action_type or "setup" in action.action_type:
                    resources_reserved.append(action.action_type)
            else:
                logs.append(ExecutionLog(
                    log_id=str(uuid.uuid4()), case_id=case_id, action_id=action.action_id,
                    event_type="action_failed_attempt", status=ExecutionStatus.FAILED,
                    message=f"Action '{action.title}' failed on attempt {attempt + 1}.",
                    retry_count=attempt
                ))
                recovered, rec_log = handle_failure(action, attempt, max_retries, case_id)
                logs.append(rec_log)
                if rec_log.status == ExecutionStatus.RETRIED:
                    attempt += 1
                elif rec_log.status == ExecutionStatus.FALLBACK_USED:
                    action.status = ActionStatus.RECOVERED
                    recovery_steps.append(action.fallback_action)
                    success = True # Fallback succeeded
                else:
                    action.status = ActionStatus.FAILED
                    break
                    
    # Generate Outcome Metrics
    outcome = OutcomeMetrics(
        case_id=case_id,
        before_queue_position=15,
        after_queue_position=1 if any(a.action_type == "alert_doctor" for a in actions) else 10,
        before_expected_wait_minutes=initial_wait,
        after_expected_wait_minutes=5 if any(a.action_type == "alert_doctor" for a in actions) else max(0, initial_wait - 10),
        risk_score=0.9 if any(a.action_type == "alert_doctor" for a in actions) else 0.5,
        alerts_sent=alerts_sent,
        resources_reserved=resources_reserved,
        recovery_steps_used=recovery_steps,
        notes=["Execution simulation completed."]
    )
    
    # Save logs and outcomes
    logs_dir = ROOT / "logs"
    logs_dir.mkdir(exist_ok=True)
    
    log_data = [l.model_dump(mode='json') for l in logs]
    (logs_dir / f"action_execution_log_{case_id}.json").write_text(json.dumps(log_data, indent=2))
    
    outcome_data = outcome.model_dump(mode='json')
    (logs_dir / f"outcome_metrics_{case_id}.json").write_text(json.dumps(outcome_data, indent=2))
    
    return actions, logs, outcome
