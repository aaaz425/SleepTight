# app/models/response.py
from pydantic import BaseModel, Field
from typing import List
from models.suggestion import ActivitySuggestion

class CoachingResponseDTO(BaseModel):
    """수면 코칭 응답 DTO"""
    activity_list: List[ActivitySuggestion]
