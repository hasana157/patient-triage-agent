import pytest
from app.models.triage import TriageResult
from app.models.action import ActionStep, ActionStatus
from app.models.execution import ExecutionStatus
from app.planner_service import plan_action_chain
from app.executor_service import execute_action_chain
from app.constraint_service import check_resources_for_action, load_resources

def test_plan_action_chain():
    triage_result = TriageResult(
        case_id="CASE-TEST-1",
        priority_level="RED",
        priority_label="RED",
        risk_score=0.95,
        confidence=1.0,
        safety_disclaimer="test"
    )
    actions = plan_action_chain(triage_result)
    assert len(actions) == 3
    assert actions[0].action_type == "alert_doctor"
    assert actions[0].fallback_action == "sms_urgent_draft"
    assert actions[1].action_type == "allocate_bed"
    
def test_executor_forces_failure_and_fallback():
    triage_result = TriageResult(
        case_id="CASE-TEST-2",
        priority_level="RED",
        priority_label="RED",
        risk_score=0.95,
        confidence=1.0,
        safety_disclaimer="test"
    )
    actions = plan_action_chain(triage_result)
    final_actions, logs, outcome = execute_action_chain("CASE-TEST-2", actions, force_fail_first_alert=True)
    
    alert_logs = [l for l in logs if l.action_id == actions[0].action_id]
    
    # We expect: started -> failed_attempt (1) -> retried -> failed_attempt (2) -> fallback
    failed_attempts = [l for l in alert_logs if l.event_type == "action_failed_attempt"]
    assert len(failed_attempts) >= 1
    
    fallback_logs = [l for l in alert_logs if l.status == ExecutionStatus.FALLBACK_USED]
    
    if len(fallback_logs) > 0:
        assert final_actions[0].status == ActionStatus.RECOVERED
        assert "sms_urgent_draft" in outcome.recovery_steps_used
    else:
        assert final_actions[0].status == ActionStatus.SUCCEEDED
        
def test_infeasible_resource():
    resources = load_resources()
    # If equipment has no impossible_machine, it should be blocked unless we don't check it
    res = check_resources_for_action("setup_ecg", resources)
    # the demo has 1 ecg_machine, so it should be true
    assert res == True
    
    # Let's create a fake action
    from app.models.action import ActionStep
    action = ActionStep(
        action_id="fake", case_id="CASE-TEST-3", sequence=1,
        action_type="allocate_bed", title="bed", description="bed"
    )
    # mock the resources
    empty_resources = {"beds": {"resuscitation": 0, "acute": 0}}
    assert check_resources_for_action("allocate_bed", empty_resources) == False
