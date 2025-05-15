# app/main.py
import uvicorn
from fastapi import FastAPI
from threading import Thread
from contextlib import asynccontextmanager
from consumer import start_consumer

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    FastAPI Lifespan 핸들러:
    - 앱 시작 시(startup): RabbitMQ 소비자 스레드 실행
    - 앱 종료 시(shutdown): 필요한 정리 작업을 여기서 수행 가능
    """
    # --- startup code ---
    consumer_thread = Thread(target=start_consumer, daemon=True)
    consumer_thread.start()
    # 앱 실행 계속
    yield
    # --- shutdown code (필요 시) ---
    # 예: consumer 연결 끊기, 리소스 해제 등

# FastAPI 인스턴스 생성 시 lifespan 등록
app = FastAPI(
    title="Sleep Sound Detection API",
    openapi_url=None,      # RunPod 환경에 따라 OpenAPI 문서 비활성화
    lifespan=lifespan      # Lifespan 이벤트 핸들러 등록
)

# uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
