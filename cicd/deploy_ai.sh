#!/bin/bash
set -e

# Optional: Ensure docker-compose is on PATH
export PATH=$PATH:/usr/local/bin

APP_DIR="/home/ubuntu/sleep-tight-app"
COMPOSE_FILE="${APP_DIR}/docker-compose.yml"
AI_SERVICE="ai"
HEALTH_URL="http://127.0.0.1:8082/health"
MAX_RETRIES=10
RETRY_INTERVAL=5

echo "=== AI 서비스 배포 시작 ==="

# 1) 최신 이미지 풀
docker-compose -f $COMPOSE_FILE pull $AI_SERVICE

# 2) 기존 컨테이너 정리
docker-compose -f $COMPOSE_FILE stop $AI_SERVICE 2>/dev/null || true
docker-compose -f $COMPOSE_FILE rm -f $AI_SERVICE 2>/dev/null || true

# 3) 새 컨테이너 실행
docker-compose -f $COMPOSE_FILE up -d --no-deps $AI_SERVICE

# 4) 헬스체크 (B 방식 적용)
echo "헬스체크: $HEALTH_URL"
set +e
OK=0
for i in $(seq 1 $MAX_RETRIES); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_URL)
  if [ "$HTTP_CODE" == "200" ]; then
    echo "✅ AI 서비스 준비 완료"
    OK=1
    break
  fi
  echo "⏳ ($i/$MAX_RETRIES) 준비 중... (HTTP $HTTP_CODE)"
  sleep $RETRY_INTERVAL
done
set -e

if [ $OK -ne 1 ]; then
  echo "❌ AI 서비스 헬스체크 실패"
  exit 1
fi

echo "=== AI 서비스 배포 완료 ==="
exit 0
