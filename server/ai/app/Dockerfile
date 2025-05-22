# ──────────────────────────────────────────────────────────
# 파일: server/ai/Dockerfile
# ──────────────────────────────────────────────────────────

# 1단계: 의존성 설치용 빌더 이미지
FROM python:3.10-alpine AS builder
WORKDIR /app

# 의존성 파일 복사 및 설치
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# (선택) 모델 파일 등 추가 리소스 복사
# COPY models/ ./models/

# ──────────────────────────────────────────────────────────

# 2단계: 런타임 전용 슬림 이미지
FROM python:3.10-alpine
WORKDIR /app

# curl 설치 (헬스체크용)
RUN apk add --no-cache curl

# 빌더 단계에서 설치된 라이브러리만 복사
COPY --from=builder /usr/local/lib/python3.10/site-packages/ \
     /usr/local/lib/python3.10/site-packages/

# 애플리케이션 코드 복사
COPY . .

# FastAPI 포트 노출
EXPOSE 8081

# 헬스체크 설정
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8081/api/health || exit 1

# 컨테이너 시작 시 Uvicorn 실행
CMD ["python", "-m", "uvicorn", "main:app", \
     "--host", "0.0.0.0", "--port", "8081"]
