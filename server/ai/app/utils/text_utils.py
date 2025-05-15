# app/utils/text_utils.py
from typing import List, Union
from app.models.request import WeeklyDataItem, NightDataItem

# 영문 코드 → 한글 라벨 매핑
DATA_TYPE_LABELS = {
    "WATER": "수분 섭취량",
    "MOMENTUM": "운동량",
    "WALK": "걸음 수",
    "TOTAL_ENERGY_BURNED": "활동 에너지 소모량",
    "CAFFEINE": "카페인",
    "CALORIE": "열량",
    "CHOLESTEROL": "콜레스테롤",
    "VITAMIN_D": "비타민D",
    "SUGAR": "당",
    "LIGHT": "얕은 수면",
    "DEEP": "깊은 수면",
    "REM": "렘수면",
    "AWAKE": "깨어있는 시간",
    "SLEEP_SCORE": "수면 정도"
}

# 영문 단위 → 한글 단위 매핑
UNIT_LABELS = {
    "LITER": "리터",
    "SECOND": "초",
    "STEP": "걸음",
    "KILOCALORIE": "kcal",
    "GRAMS": "g",
    "MINUTE": "분",
    "SCORE": "점수"
}

def items_to_text(items: List[Union[WeeklyDataItem, NightDataItem]]) -> str:
    """
    리스트 형식의 데이터 아이템을 '한글 라벨 값단위' 멀티라인 텍스트로 변환
    """
    lines = []
    for item in items:
        label = DATA_TYPE_LABELS.get(item.dataType, item.dataType)
        unit = UNIT_LABELS.get(item.unit, item.unit)
        lines.append(f"{label} {item.value}{unit}")
    return "\n".join(lines)
