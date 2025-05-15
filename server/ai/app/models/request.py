# app/models/request.py
from pydantic import BaseModel, Field
from typing import Dict, Any

class CoachingRequestDTO(BaseModel):
    """수면 코칭 요청 DTO"""
    weekly_data: Dict[str, Any] = Field(..., description="주간 활동 데이터(key: 값)")
    night_data: Dict[str, Any] = Field(..., description="야간 수면 데이터(key: 값)")
    