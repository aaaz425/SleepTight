# app/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """환경변수 설정: .env 또는 시스템 환경 변수를 로드"""
    OPENAI_API_KEY: str
    PINECONE_API_KEY: str
    PINECONE_ENVIRONMENT: str
    PINECIONE_INDEX_NAME: str
    MODEL_NAME: str = "gpt-4o"
    EMBEDDING_MODEL: str = "text-embedding-3-large"
    TOP_K: int = 2

    class Config:
        env_file = "app/.env"

settings = Settings()
