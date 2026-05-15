from __future__ import annotations

from datetime import datetime
from enum import StrEnum
from typing import Any

from pydantic import BaseModel, Field


class ExecutionStatus(StrEnum):
    INFO = "info"
    SUCCEEDED = "succeeded"
    FAILED = "failed"
    RETRIED = "retried"
    FALLBACK_USED = "fallback_used"
    MANUAL_REVIEW = "manual_review"


class ExecutionLog(BaseModel):
    log_id: str
    case_id: str
    action_id: str | None = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    event_type: str
    status: ExecutionStatus
    message: str
    retry_count: int = Field(default=0, ge=0)
    evidence: dict[str, Any] = Field(default_factory=dict)

