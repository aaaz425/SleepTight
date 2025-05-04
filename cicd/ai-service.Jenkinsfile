pipeline {
  agent any

  environment {
    // Docker 레지스트리 정보
    DOCKER_REGISTRY   = 'xylitol311'
    AI_IMAGE          = 'sleep-tight-ai'

    // 공통 Credentials
    ENV_FILE_ID       = 'env-file-credential'
    DOCKER_HUB_CRED   = 'docker-hub-credentials'

    // Git 설정
    GIT_BRANCH        = 'dev/be'
    GIT_URL           = 'https://lab.ssafy.com/s12-final/S12P31S303.git'

    // EC2 배포 디렉토리 및 Compose 경로
    REMOTE_APP_DIR    = '/home/ubuntu/sleep-tight-app'
    COMPOSE_FILE_PATH = 'cicd/docker-compose.yml'
  }

  stages {
    stage('Checkout & Prepare') {
      steps {
        git branch: "${GIT_BRANCH}",
            credentialsId: 'gitlab-access-token-credential',
            url: "${GIT_URL}"

        withCredentials([file(credentialsId: "${ENV_FILE_ID}", variable: 'ENV_FILE')]) {
          sh '''
            set -e
            cp "$ENV_FILE" ./.env
          '''
        }
      }
    }

    stage('Docker Login') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: "${DOCKER_HUB_CRED}",
          usernameVariable: 'DOCKERHUB_USR',
          passwordVariable: 'DOCKERHUB_PSW'
        )]) {
          sh 'echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin'
        }
      }
    }

    stage('Build & Push AI') {
      steps {
        sh '''
          # 1) AI 서비스 빌드(필요 시 의존성 설치)
          cd server/ai
          # pip install -r requirements.txt  # uncomment 필요 시

          # 2) Docker 이미지 태깅 및 푸시
          IMAGE_TAG=${DOCKER_REGISTRY}/${AI_IMAGE}:${BUILD_NUMBER}
          LATEST_TAG=${DOCKER_REGISTRY}/${AI_IMAGE}:latest

          docker build -t "$IMAGE_TAG" .
          docker tag "$IMAGE_TAG" "$LATEST_TAG"
          docker push "$IMAGE_TAG"
          docker push "$LATEST_TAG"
        '''
      }
    }

    stage('Deploy AI') {
      steps {
        sh '''
          mkdir -p "$REMOTE_APP_DIR"
          cp ./.env "$REMOTE_APP_DIR"/.env
          cp "$COMPOSE_FILE_PATH" "$REMOTE_APP_DIR"/docker-compose.yml
          cp cicd/deploy_ai.sh "$REMOTE_APP_DIR"/deploy_ai.sh
          chmod +x "$REMOTE_APP_DIR"/deploy_ai.sh

          cd "$REMOTE_APP_DIR"
          bash ./deploy_ai.sh
        '''
      }
    }
  }

  post {
    always {
      sh 'docker logout'
      cleanWs()
    }
    success {
      echo 'AI 서비스 배포가 성공적으로 완료되었습니다.'
    }
    failure {
      echo 'AI 서비스 배포 중 오류가 발생했습니다.'
    }
  }
}