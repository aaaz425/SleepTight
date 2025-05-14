# app/models/suggestion.py
from pydantic import BaseModel, Field

class ActivitySuggestion(BaseModel):
    """추천 활동 객체"""
    activity: str = Field(..., description="활동 이름(소문자_언더바)")
    type: str = Field(..., description="total 또는 min 또는 max")
    value: float = Field(..., description="추천 수치")
    description: str = Field(..., description="추천 근거 설명(50자 내외)")
    