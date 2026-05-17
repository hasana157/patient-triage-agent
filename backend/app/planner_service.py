import uuid
from app.models.action import ActionStep, ActionStatus
from app.models.triage import TriageResult

def plan_action_chain(triage_result: TriageResult) -> list[ActionStep]:
    """
    AGENTIC AI MODULE: Action Workflow Planner
    
    This function translates the analytical 'TriageResult' into a concrete operational
    execution plan. It acts as the 'planning' phase of the agentic loop.
    
    Key agentic behaviors:
    - Multi-step Planning: Generates a sequence of interconnected tasks (e.g., Alert -> Allocate -> Setup).
    - Dependency Graphing: Uses `depends_on` to ensure actions are executed in the correct order.
    - Fallback Generation: Pre-computes fallback actions (e.g., if 'alert_doctor' fails, use 'sms_urgent_draft').
    - Constraint Awareness: Assigns targets and deadlines based on priority.
    """
    actions = []
    case_id = triage_result.case_id
    
    if triage_result.priority_level == "RED":
        actions.append(ActionStep(
            action_id=str(uuid.uuid4()), case_id=case_id, sequence=1,
            action_type="alert_doctor", title="Alert Emergency Doctor",
            description="Immediate life-saving intervention required.",
            target_role="emergency_doctor", deadline_minutes=1,
            fallback_action="sms_urgent_draft"
        ))
        actions.append(ActionStep(
            action_id=str(uuid.uuid4()), case_id=case_id, sequence=2,
            action_type="allocate_bed", title="Allocate Resuscitation Bed",
            description="Secure red zone bed for incoming critical patient.",
            depends_on=[actions[0].action_id],
            target_role="senior_nurse"
        ))
        actions.append(ActionStep(
            action_id=str(uuid.uuid4()), case_id=case_id, sequence=3,
            action_type="setup_ecg", title="Setup ECG & Oxygen",
            description="Prepare equipment for immediate arrival.",
            depends_on=[actions[1].action_id],
            target_role="triage_nurse"
        ))
    elif triage_result.priority_level == "MANUAL_REVIEW":
        actions.append(ActionStep(
            action_id=str(uuid.uuid4()), case_id=case_id, sequence=1,
            action_type="request_vitals", title="Request Missing Vitals/Clarification",
            description="Collect missing information or resolve contradiction.",
            target_role="triage_nurse", deadline_minutes=10,
        ))
        actions.append(ActionStep(
            action_id=str(uuid.uuid4()), case_id=case_id, sequence=2,
            action_type="senior_review", title="Senior Nurse Review",
            description="Manual override and review needed.",
            depends_on=[actions[0].action_id],
            target_role="senior_nurse", deadline_minutes=15
        ))
        actions.append(ActionStep(
            action_id=str(uuid.uuid4()), case_id=case_id, sequence=3,
            action_type="place_in_queue", title="Place in Queue",
            description="Assign temporary wait status pending review.",
            depends_on=[actions[1].action_id]
        ))
    else:
        # Standard green/yellow/orange path
        actions.append(ActionStep(
            action_id=str(uuid.uuid4()), case_id=case_id, sequence=1,
            action_type="place_in_queue", title="Standard Queue Assignment",
            description="Assign to waiting room.",
            target_role="triage_nurse"
        ))
        actions.append(ActionStep(
            action_id=str(uuid.uuid4()), case_id=case_id, sequence=2,
            action_type="periodic_reassessment", title="Schedule Reassessment",
            description="Reassess patient later.",
            depends_on=[actions[0].action_id],
            target_role="triage_nurse", deadline_minutes=30
        ))
        
    return actions
