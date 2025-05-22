# app/models/request.py
from pydantic import BaseModel, Field
from typing import List, Literal

class WeeklyDataItem(BaseModel):
    dataType: Literal[
        "WATER", "MOMENTUM", "WALK", "TOTAL_ENERGY_BURNED",
        "CAFFEINE", "CALORIE", "CHOLESTEROL", "VITAMIN_D", "SUGAR"
    ]
    value: float
    unit: Literal["LITER", "SECOND", "STEP", "KILOCALORIE", "GRAMS"]

class NightDataItem(BaseModel):
    dataType: Literal["LIGHT", "DEEP", "REM", "AWAKE", "SLEEP_SCORE"]
    value: float
    unit: Literal["MINUTE", "SCORE"]

class CoachingRequestDTO(BaseModel):
    """수면 코칭 요청 DTO"""
    weekly_data: List[WeeklyDataItem] = Field(..., description="주간 활동 데이터 리스트")
    night_data: List[NightDataItem] = Field(..., description="야간 수면 데이터 리스트")
