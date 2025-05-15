# app/utils/text_utils.py
from typing import Dict, Any

def dict_to_text(data: Dict[str, Any]) -> str:
    """
    dict를 'key: value' 형태의 멀티라인 문자열로 변환
    """
    return "\n".join(f"{key}: {value}" for key, value in data.items())
