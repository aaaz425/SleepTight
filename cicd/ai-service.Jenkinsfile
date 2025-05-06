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

    // EC2 SSH 설정
    DEPLOY_USER       = 'ubuntu'
    DEPLOY_HOST       = '43.202.63.167'
    SSH_CREDENTIAL_ID = 'ec2-ssh-key'

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
          sh '''
            #!/bin/bash -e
            echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin \
              || { echo "[ERROR] Docker login failed"; exit 1; }
          '''
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
        sshagent(credentials: [SSH_CREDENTIAL_ID]) {
          sh """
            # 1) 배포 디렉토리 생성 (ubuntu 권한으로)
            ssh -o StrictHostKeyChecking=no \$DEPLOY_USER@\$DEPLOY_HOST \\
              "mkdir -p \$REMOTE_APP_DIR"

            # 2) 파일 복사 (.env, docker-compose.yml, 스크립트)
            scp -o StrictHostKeyChecking=no ./.env \\
                \$DEPLOY_USER@\$DEPLOY_HOST:\$REMOTE_APP_DIR/.env
            scp -o StrictHostKeyChecking=no \$COMPOSE_FILE \\
                \$DEPLOY_USER@\$DEPLOY_HOST:\$REMOTE_APP_DIR/docker-compose.yml
            scp -o StrictHostKeyChecking=no cicd/deploy_ai.sh \\
                \$DEPLOY_USER@\$DEPLOY_HOST:\$REMOTE_APP_DIR/deploy_ai.sh

            # 3) 권한 부여 및 실행
            ssh -o StrictHostKeyChecking=no \$DEPLOY_USER@\$DEPLOY_HOST \\
              "chmod +x \$REMOTE_APP_DIR/deploy_ai.sh && \\
               cd \$REMOTE_APP_DIR && ./deploy_ai.sh"
          """
        }
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
