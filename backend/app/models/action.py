from __future__ import annotations

from enum import StrEnum

from pydantic import BaseModel, Field


class ActionStatus(StrEnum):
    PLANNED = "planned"
    BLOCKED = "blocked"
    RUNNING = "running"
    SUCCEEDED = "succeeded"
    FAILED = "failed"
    RECOVERED = "recovered"


class ActionStep(BaseModel):
    action_id: str
    case_id: str
    sequence: int = Field(ge=1, le=5)
    action_type: str
    title: str
    description: str
    status: ActionStatus = ActionStatus.PLANNED
    depends_on: list[str] = Field(default_factory=list)
    target_role: str | None = None
    deadline_minutes: int | None = Field(default=None, ge=0)
    fallback_action: str | None = None
    clinician_confirmation_required: bool = True

