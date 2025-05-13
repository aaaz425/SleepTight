import logging
from fastapi import FastAPI
from app.config import settings
from app.routers.coaching import router as coaching_router

# 필수 환경변수 검증
if not settings.OPENAI_API_KEY or not settings.PINECONE_API_KEY:
    logging.error("OPENAI_API_KEY와 PINECONE_API_KEY를 설정해주세요.")

app = FastAPI(
    title="Sleep Coaching RAG API",
    description="Retrieval Augmented Generation 기반의 수면 코칭 제공 API"
)

# 코칭 라우터 등록
app.include_router(coaching_router, prefix="/coaching", tags=["coaching"])
