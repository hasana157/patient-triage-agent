from __future__ import annotations

from pydantic import BaseModel, Field


class OutcomeMetrics(BaseModel):
    case_id: str
    before_queue_position: int = Field(ge=1)
    after_queue_position: int = Field(ge=1)
    before_expected_wait_minutes: int = Field(ge=0)
    after_expected_wait_minutes: int = Field(ge=0)
    risk_score: float = Field(ge=0.0, le=1.0)
    alerts_sent: int = Field(default=0, ge=0)
    resources_reserved: list[str] = Field(default_factory=list)
    recovery_steps_used: list[str] = Field(default_factory=list)
    notes: list[str] = Field(default_factory=list)

