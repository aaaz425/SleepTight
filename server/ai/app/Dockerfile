# ──────────────────────────────────────────────────────────
# 파일: server/ai/Dockerfile
# ──────────────────────────────────────────────────────────

# 1단계: 의존성 설치를 위한 빌드 이미지
FROM python:3.10-alpine AS builder

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 파일 복사 후 캐싱 활용하여 설치
COPY app/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# (필요 시) 모델 파일 다운로드 또는 복사
# 예: COPY models/ ./models/

# 2단계: 런타임 이미지에 결과물을 복사
FROM python:3.10-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 빌드 이미지에서 설치된 라이브러리 복사
COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/

# 애플리케이션 소스 복사
COPY . .

# FastAPI 기본 포트 노출
EXPOSE 8081

# 컨테이너 시작 시 FastAPI 앱 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8081"]

# (선택) 헬스체크 설정 예시
# HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
#   CMD curl -f http://localhost:8081/health || exit 1