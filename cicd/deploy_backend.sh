#!/bin/bash
set -e

APP_DIR="/home/ubuntu/sleep-tight-app"
COMPOSE_FILE="${APP_DIR}/docker-compose.yml"
NGINX_CONF="/etc/nginx/conf.d/service-url.inc"
HEALTH_ENDPOINT="/api/utils/status"
MAX_RETRIES=20
RETRY_INTERVAL=5

echo "=== 백엔드 Blue/Green 배포 시작 ==="

# 현재 Nginx가 바라보는 포트 확인 (초기값: 8080)
CURRENT_PORT=$(grep -oP '127\.0\.0\.1:\K[0-9]+' $NGINX_CONF || echo "8080")
if [ "$CURRENT_PORT" == "8080" ]; then
  NEXT_COLOR="green"; NEXT_SERVICE="backend-green"; NEXT_PORT=8081
  PREV_PORT=8080; PREV_SERVICE="backend-blue"
else
  NEXT_COLOR="blue"; NEXT_SERVICE="backend-blue"; NEXT_PORT=8080
  PREV_PORT=8081; PREV_SERVICE="backend-green"
fi

echo "배포 대상: $NEXT_SERVICE (포트: $NEXT_PORT)"

# 1) 최신 이미지 풀
docker-compose -f $COMPOSE_FILE pull $NEXT_SERVICE

# 2) 이전 (같은 컬러) 컨테이너 정리
docker-compose -f $COMPOSE_FILE stop $NEXT_SERVICE 2>/dev/null || true
docker-compose -f $COMPOSE_FILE rm -f $NEXT_SERVICE 2>/dev/null || true

# 3) 새 컨테이너 실행
docker-compose -f $COMPOSE_FILE up -d --no-deps $NEXT_SERVICE

# 4) 헬스체크
echo "헬스체크: http://127.0.0.1:${NEXT_PORT}${HEALTH_ENDPOINT}"
for i in $(seq 1 $MAX_RETRIES); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:$NEXT_PORT$HEALTH_ENDPOINT)
  if [ "$HTTP_CODE" == "200" ]; then
    echo "✅ 새 컨테이너 준비 완료"
    break
  fi
  echo "⏳ ($i/$MAX_RETRIES) 준비 중..."
  sleep $RETRY_INTERVAL
  if [ $i -eq $MAX_RETRIES ]; then
    echo "❌ 헬스체크 실패, 롤백"
    # Nginx 원복
    echo "set \$service_url http://127.0.0.1:${PREV_PORT};" | sudo tee $NGINX_CONF >/dev/null
    sudo nginx -s reload
    # 새 컨테이너 삭제
    docker-compose -f $COMPOSE_FILE stop $NEXT_SERVICE
    docker-compose -f $COMPOSE_FILE rm -f $NEXT_SERVICE
    exit 1
  fi
done

# 5) Nginx 트래픽 전환
echo "set \$service_url http://127.0.0.1:${NEXT_PORT};" | sudo tee $NGINX_CONF >/dev/null
sudo nginx -s reload

# 6) 이전 컨테이너 정리
docker-compose -f $COMPOSE_FILE stop $PREV_SERVICE 2>/dev/null || true
docker-compose -f $COMPOSE_FILE rm -f $PREV_SERVICE 2>/dev/null || true

echo "=== 백엔드 배포 완료: $NEXT_SERVICE 활성화 ==="
exit 0