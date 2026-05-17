import uuid
from pathlib import Path
import pytest
import os
import json

from app.executor_service import execute_action_chain
from app.recovery_service import handle_failure
from app.models.action import ActionStep, ActionStatus
from app.models.execution import ExecutionStatus

def create_action(action_type, fallback=None):
    return ActionStep(
        action_id=str(uuid.uuid4()),
        case_id="CASE-001",
        sequence=1,
        action_type=action_type,
        title=f"Test {action_type}",
        description="Test desc",
        fallback_action=fallback
    )

def test_full_red_case_execution():
    actions = [
        create_action("alert_doctor", fallback="sms_urgent_draft"),
        ActionStep(
            action_id=str(uuid.uuid4()), case_id="CASE-001", sequence=2,
            action_type="allocate_bed", title="Allocate Resuscitation Bed",
            description="desc"
        ),
        ActionStep(
            action_id=str(uuid.uuid4()), case_id="CASE-001", sequence=3,
            action_type="setup_ecg", title="Setup ECG",
            description="desc"
        ),
        ActionStep(
            action_id=str(uuid.uuid4()), case_id="CASE-001", sequence=4,
            action_type="prepare_meds", title="Prep meds",
            description="desc"
        ),
        ActionStep(
            action_id=str(uuid.uuid4()), case_id="CASE-001", sequence=5,
            action_type="notify_family", title="Notify family",
            description="desc"
        )
    ]
    actions[0].fallback_action = "sms_urgent_draft"
    
    final_actions, logs, outcome = execute_action_chain("CASE-001", actions, force_fail_first_alert=True)
    
    assert len(logs) > 0
    assert outcome.case_id == "CASE-001"
    
    statuses = [log.status for log in logs]
    assert ExecutionStatus.FAILED in statuses
    assert ExecutionStatus.FALLBACK_USED in statuses or ExecutionStatus.RETRIED in statuses

def test_forced_alert_failure_triggers_recovery():
    actions = [create_action("alert_doctor", fallback="sms_urgent_draft")]
    
    final_actions, logs, outcome = execute_action_chain("CASE-001", actions, force_fail_first_alert=True)
    
    log_types = [log.event_type for log in logs]
    
    assert "action_failed_attempt" in log_types
    assert "action_retry" in log_types or "action_fallback" in log_types
    
    assert final_actions[0].status in [ActionStatus.RECOVERED, ActionStatus.FAILED]
    
    # Check log message contains fallback or retry
    recovery_logs = [log for log in logs if "fallback" in log.message.lower() or "retry" in log.message.lower()]
    assert len(recovery_logs) > 0

def test_successful_non_alert_action():
    actions = [create_action("recheck_vitals")]
    
    final_actions, logs, outcome = execute_action_chain("CASE-002", actions, force_fail_first_alert=False)
    
    assert final_actions[0].status == ActionStatus.SUCCEEDED
    
    log_types = [log.event_type for log in logs]
    assert "action_completed" in log_types

def test_outcome_metrics_are_generated():
    actions = [create_action("allocate_bed")]
    
    final_actions, logs, outcome = execute_action_chain("CASE-003", actions)
    
    condition_met = (
        outcome.before_queue_position > outcome.after_queue_position or
        outcome.before_expected_wait_minutes >= outcome.after_expected_wait_minutes
    )
    assert condition_met
    
    # Check if files exist
    ROOT = Path(__file__).resolve().parent.parent / "app"
    logs_dir = ROOT / "logs"
    assert (logs_dir / "action_execution_log_CASE-003.json").exists()
    assert (logs_dir / "outcome_metrics_CASE-003.json").exists()

def test_recovery_service_retry_logic():
    action = create_action("alert_doctor")
    
    # attempt=0, max_retries=1
    recovered, log = handle_failure(action, 0, 1, "CASE-004")
    assert log.status == ExecutionStatus.RETRIED
    
    # attempt=1, max_retries=1, fallback_action set
    action.fallback_action = "sms_urgent_draft"
    recovered, log = handle_failure(action, 1, 1, "CASE-004")
    assert log.status == ExecutionStatus.FALLBACK_USED
    
    # attempt=1, max_retries=1, fallback_action=None
    action.fallback_action = None
    recovered, log = handle_failure(action, 1, 1, "CASE-004")
    assert log.status == ExecutionStatus.FAILED
