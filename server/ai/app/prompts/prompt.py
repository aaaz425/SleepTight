# app/prompts/prompt.py
from langchain.prompts import PromptTemplate

# 1) RAG 내러티브용 프롬프트
prompt_rag = PromptTemplate(
    input_variables=["context", "question"],
    template="""
다음은 수면 관련 논문에서 추출된 정보입니다:
{context}

사용자 질문:
{question}

위 정보를 종합하여, **내러티브 형식**으로 오늘 밤 더 깊고 질 좋은 수면을 위한  
구체적인 코칭 문구를 작성하세요.
- **하이픈(-)은 사용하지 않는 마크다운 형식**으로 작성해주세요.
- 말투는 **친근하고 따뜻한 격려 톤**으로 유지하며,  
  '수고 많으셨습니다', '꿈속에서 만나요' 등의 표현을 자연스럽게 활용하세요.
- **전체 분량은 400자 분량** 수준으로 간결하게 요약하세요.
- 논문을 포함한 제시된 근거에 기반한 **추천 목표치**가 있을 경우, 자연스럽게 기재하고, 없으면 생략하세요.
- **핵심 데이터 및 수치, 필요 시 추천 목표치**는 마크다운 색상(#7A6FF0, #FF6961)으로 강조합니다.
"""
)

# 2) JSON 제안용 프롬프트
prompt_json = PromptTemplate(
    input_variables=["weekly_data", "coaching_text"],
    template="""
사용자의 주간 활동 데이터:
{weekly_data}

생성된 코칭 문구:
{coaching_text}

위 코칭 문구에서 **오직 주간 활동 데이터 항목**(야간 수면 데이터는 제외) 중  
**최대 3가지**를 골라, 추천 목적에 맞게 **총량(total) 또는 최소(min)** 형태의  
JSON 배열을 만드세요.

- 각 객체 형식:
  {{ "activity": "(소문자_언더바)", "type": "total|min", "value": 숫자 }}

**출력 규칙 (꼭 지킬 것)**  
1. 순수 JSON 배열(`[`…`]`) 형태만 출력  
2. 코드펜스(backtick), 추가 설명문 일체 금지  
3. 줄바꿈 없이 한 줄 JSON 문자열로 반환
"""
)
