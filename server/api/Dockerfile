# ──────────────────────────────────────────────────────────
# 파일: server/api/Dockerfile
# ──────────────────────────────────────────────────────────

# 1단계: 애플리케이션 빌드를 위한 이미지
FROM node:lts-alpine AS builder

# 작업 디렉토리 설정
WORKDIR /app

# package 파일 복사 후 devDependencies 포함 설치
COPY package*.json ./
RUN npm install --production=false

# 소스 코드 복사 및 빌드 실행
COPY . .
RUN npm run build

# 2단계: 프로덕션 이미지 준비
FROM node:lts-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 운영 의존성만 설치
COPY package*.json ./
RUN npm install --production

# 빌드된 결과물(dist 디렉토리) 복사
COPY --from=builder /app/dist ./dist

# NestJS 기본 포트 노출
EXPOSE 3000

# 컨테이너 시작 시 애플리케이션 실행
CMD ["node", "dist/main.js"]

# (선택) 헬스체크 설정 예시
# HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
#   CMD curl -f http://localhost:3000/api/utils/status || exit 1