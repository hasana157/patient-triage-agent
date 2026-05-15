from __future__ import annotations

from enum import StrEnum

from pydantic import BaseModel, Field


class PriorityLevel(StrEnum):
    RED = "RED"
    ORANGE = "ORANGE"
    YELLOW = "YELLOW"
    GREEN = "GREEN"
    BLUE = "BLUE"
    MANUAL_REVIEW = "MANUAL_REVIEW"


class Contradiction(BaseModel):
    conflict_type: str
    severity: str = Field(description="Prototype values: low, medium, high, critical.")
    evidence_a: str
    evidence_b: str
    resolution_action: str


class TriageResult(BaseModel):
    case_id: str
    priority_level: PriorityLevel
    priority_label: str
    risk_score: float = Field(ge=0.0, le=1.0)
    confidence: float = Field(ge=0.0, le=1.0)
    red_flags: list[str] = Field(default_factory=list)
    contradictions: list[Contradiction] = Field(default_factory=list)
    missing_fields: list[str] = Field(default_factory=list)
    reasoning: list[str] = Field(default_factory=list)
    recommended_actions: list[str] = Field(default_factory=list)
    safety_disclaimer: str = (
        "Prototype decision support only. This is not a diagnosis. "
        "A licensed clinician must confirm or override the priority."
    )

