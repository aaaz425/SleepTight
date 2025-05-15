#!/bin/bash
set -euo pipefail

APP_DIR="/home/ubuntu/sleep-tight-app"
COMPOSE_FILE="${APP_DIR}/docker-compose.yml"
AI_SERVICE="ai"
HOST_PORT=8082
HEALTH_ENDPOINT="/api/health"
MAX_RETRIES=10
RETRY_INTERVAL=5
INITIAL_WAIT=5

echo "=== AI 서비스 배포 시작 ==="

# 1) 최신 이미지 풀
docker compose -f "$COMPOSE_FILE" pull "$AI_SERVICE"

# 2) 기존 컨테이너 정리
docker compose -f "$COMPOSE_FILE" stop "$AI_SERVICE" 2>/dev/null || true
docker compose -f "$COMPOSE_FILE" rm -f "$AI_SERVICE"   2>/dev/null || true

# 3) 새 컨테이너 실행
docker compose -f "$COMPOSE_FILE" up -d --no-deps "$AI_SERVICE"

# 4) 초기 기동 대기
echo "⏳ 컨테이너 초기 기동 대기 (${INITIAL_WAIT}s)..."
sleep "$INITIAL_WAIT"

# 5) 헬스체크
echo "🔍 헬스체크: http://127.0.0.1:${HOST_PORT}${HEALTH_ENDPOINT}"
for (( i=1; i<=MAX_RETRIES; i++ )); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://127.0.0.1:${HOST_PORT}${HEALTH_ENDPOINT}" || true)

  if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ AI 서비스 준비 완료"
    exit 0
  fi

  echo "⏳ (${i}/${MAX_RETRIES}) 준비 중... (HTTP $HTTP_CODE)"
  sleep "$RETRY_INTERVAL"
done

# 6) 헬스체크 실패 시 로그 출력 후 종료
echo "❌ AI 서비스 헬스체크 실패 (after ${MAX_RETRIES} attempts)"
docker compose -f "$COMPOSE_FILE" logs "$AI_SERVICE" --tail=50
exit 1
