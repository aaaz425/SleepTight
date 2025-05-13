# app/models/response.py
from pydantic import BaseModel, Field
from typing import List
from app.models.suggestion import ActivitySuggestion

class CoachingResponseDTO(BaseModel):
    """수면 코칭 응답 DTO"""
    coaching_text: str = Field(..., description="생성된 코칭 문구")
    activity_list: List[ActivitySuggestion] = Field(..., description="추천된 활동 리스트")
    