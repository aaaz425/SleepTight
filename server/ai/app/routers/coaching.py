# app/routers/coaching.py
from fastapi import APIRouter, HTTPException
from app.config import settings
from app.models.request import CoachingRequestDTO
from app.models.response import CoachingResponseDTO
from app.utils.text_utils import dict_to_text
from app.prompts.prompt import prompt
from pinecone import Pinecone
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_pinecone import PineconeVectorStore
from langchain.chains import LLMChain
import os, json

router = APIRouter()

# 환경 변수로 OpenAI API 키 설정
os.environ["OPENAI_API_KEY"] = settings.OPENAI_API_KEY

# Pinecone 클라이언트 초기화
pc = Pinecone(api_key=settings.PINECONE_API_KEY, environment=settings.PINECONE_ENVIRONMENT)
index = pc.Index(settings.PINECIONE_INDEX_NAME)

# 임베딩 및 벡터 스토어 초기화
embeddings = OpenAIEmbeddings(model=settings.EMBEDDING_MODEL)
vectorstore = PineconeVectorStore(index=index, embedding=embeddings, text_key="text")
retriever = vectorstore.as_retriever(search_kwargs={"k": settings.TOP_K})

# LLM 및 LLMChain 초기화
llm = ChatOpenAI(temperature=0.7, max_tokens=1024, model_name=settings.MODEL_NAME)
combined_chain = LLMChain(llm=llm, prompt=prompt)

@router.post("/", response_model=CoachingResponseDTO)
async def generate_coaching(request: CoachingRequestDTO):
    """
    주간 및 야간 데이터를 받아 RAG 기반 논문 근거로
    JSON 형태의 활동 추천 리스트를 반환
    """
    # dict 데이터를 텍스트로 변환
    weekly_text = dict_to_text(request.weekly_data)
    night_text = dict_to_text(request.night_data)

    # 질문 형태로 컨텍스트 검색
    question = (
        f"주간 활동 데이터:\n{weekly_text}\n\n"
        f"야간 수면 데이터:\n{night_text}\n\n"
        "이처럼 기록된 사용자가 오늘 더 깊은 잠을 자려면?"
    )
    docs = retriever.get_relevant_documents(question)
    context = "\n".join([doc.page_content for doc in docs])

    # 통합 프롬프트 실행 (JSON 출력)
    out: str = combined_chain.invoke({
        "context": context,
        "weekly_data": weekly_text,
        "night_data": night_text
    })["text"]

    out = out.replace("```json", "").replace("```", "")

    # JSON 파싱
    try:
        suggestions = json.loads(out)
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail="JSON 파싱 오류: 제안 내용을 확인하세요.")

    return CoachingResponseDTO(activity_list=suggestions)
