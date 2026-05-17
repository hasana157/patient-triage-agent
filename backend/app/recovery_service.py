import uuid
from app.models.action import ActionStep
from app.models.execution import ExecutionLog, ExecutionStatus

def handle_failure(action: ActionStep, attempt: int, max_retries: int, case_id: str) -> tuple[bool, ExecutionLog]:
    """
    AGENTIC AI MODULE: Failure Recovery & Resilience
    
    This function handles action failure, providing agentic self-correction.
    Rather than failing the whole pipeline when a single step fails, the agent can:
    1. Retry: Attempt the same action again (up to max_retries).
    2. Fallback: Switch to a pre-planned alternative (e.g., SMS instead of App Notification).
    
    Returns (is_recovered, execution_log).
    """
    if attempt < max_retries:
        return True, ExecutionLog(
            log_id=str(uuid.uuid4()), case_id=case_id, action_id=action.action_id,
            event_type="action_retry", status=ExecutionStatus.RETRIED,
            message=f"Retrying action {action.action_type} (attempt {attempt + 1})", retry_count=attempt + 1
        )
    else:
        if action.fallback_action:
            return True, ExecutionLog(
                log_id=str(uuid.uuid4()), case_id=case_id, action_id=action.action_id,
                event_type="action_fallback", status=ExecutionStatus.FALLBACK_USED,
                message=f"Fallback used: {action.fallback_action}", retry_count=attempt
            )
        else:
            return False, ExecutionLog(
                log_id=str(uuid.uuid4()), case_id=case_id, action_id=action.action_id,
                event_type="action_failed", status=ExecutionStatus.FAILED,
                message=f"Action {action.action_type} failed permanently.", retry_count=attempt
            )
