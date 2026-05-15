from __future__ import annotations

from datetime import datetime
from enum import StrEnum

from pydantic import BaseModel, Field


class Sex(StrEnum):
    FEMALE = "female"
    MALE = "male"
    OTHER = "other"
    UNKNOWN = "unknown"


class Vitals(BaseModel):
    heart_rate: int | None = Field(default=None, ge=20, le=260)
    systolic_bp: int | None = Field(default=None, ge=40, le=260)
    diastolic_bp: int | None = Field(default=None, ge=20, le=180)
    respiratory_rate: int | None = Field(default=None, ge=4, le=80)
    spo2: int | None = Field(default=None, ge=40, le=100)
    temperature_c: float | None = Field(default=None, ge=25.0, le=45.0)
    consciousness: str | None = Field(
        default=None,
        description="Prototype values: alert, voice, pain, unresponsive, confused.",
    )
    recorded_at: datetime | None = None


class PatientCase(BaseModel):
    case_id: str
    patient_code: str
    age: int = Field(ge=0, le=120)
    sex: Sex = Sex.UNKNOWN
    pregnant: bool | None = None
    chief_complaint: str
    symptoms: list[str] = Field(default_factory=list)
    duration_minutes: int | None = Field(default=None, ge=0)
    pain_score: int | None = Field(default=None, ge=0, le=10)
    vitals: Vitals | None = None
    vitals_history: list[Vitals] = Field(default_factory=list)
    nurse_note: str = ""
    arrival_time: datetime | None = None
    current_wait_minutes: int = Field(default=0, ge=0)
    source: str = Field(default="synthetic_demo")

