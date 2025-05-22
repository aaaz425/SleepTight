pipeline {
  agent any

  environment {
    // Docker 레지스트리 정보
    DOCKER_REGISTRY   = 'xylitol311'
    BACKEND_IMAGE     = 'sleep-tight-backend'

    // 공통 Credentials
    ENV_FILE_ID       = 'env-file-credential'
    FCM_JSON_ID       = 'FCM_JSON_CREDENTIAL'  // Modified: FCM JSON용 Credential ID
    DOCKER_HUB_CRED   = 'docker-hub-credentials'

    // Git 설정
    GIT_BRANCH        = 'dev/be'
    GIT_URL           = 'https://lab.ssafy.com/s12-final/S12P31S303.git'
    GIT_CRED_ID       = 'gitlab-access-token-credential'

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
        // 1) 소스 코드 체크아웃
        git branch: "${GIT_BRANCH}",
            credentialsId: "${GIT_CRED_ID}",
            url: "${GIT_URL}"

        // 2) .env 파일 복사
        withCredentials([file(credentialsId: "${ENV_FILE_ID}", variable: 'ENV_FILE')]) {
          sh '''
            set -e
            cp "$ENV_FILE" ./.env
          '''
        }

        // Modified: 3) FCM JSON 키 파일 복사
        withCredentials([file(credentialsId: "${FCM_JSON_ID}", variable: 'FCM_JSON')]) {
          sh '''
            set -e
            cp "$FCM_JSON" server/api/sleep-tight-d9f9d-firebase-adminsdk-fbsvc-3fe0729751.json
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
            set -e
            docker logout || true
            echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin
            docker info
          '''
        }
      }
    }

    stage('Build & Push Backend') {
      steps {
        sh '''
          set -e
          cd server/api

          IMAGE_TAG=${DOCKER_REGISTRY}/${BACKEND_IMAGE}:${BUILD_NUMBER}
          LATEST_TAG=${DOCKER_REGISTRY}/${BACKEND_IMAGE}:latest

          docker build -t "$IMAGE_TAG" .
          docker tag "$IMAGE_TAG" "$LATEST_TAG"

          docker push "$IMAGE_TAG"
          docker push "$LATEST_TAG"
        '''
      }
    }

    stage('Deploy Backend') {
      steps {
        sshagent(credentials: [SSH_CREDENTIAL_ID]) {
          sh """
            ssh -o StrictHostKeyChecking=no \$DEPLOY_USER@\$DEPLOY_HOST "mkdir -p \$REMOTE_APP_DIR"

            scp -o StrictHostKeyChecking=no ./.env            \$DEPLOY_USER@\$DEPLOY_HOST:\$REMOTE_APP_DIR/.env
            scp -o StrictHostKeyChecking=no \$COMPOSE_FILE_PATH \$DEPLOY_USER@\$DEPLOY_HOST:\$REMOTE_APP_DIR/docker-compose.yml
            scp -o StrictHostKeyChecking=no cicd/deploy_backend.sh \$DEPLOY_USER@\$DEPLOY_HOST:\$REMOTE_APP_DIR/deploy_backend.sh

            ssh -o StrictHostKeyChecking=no \$DEPLOY_USER@\$DEPLOY_HOST \
              "chmod +x \$REMOTE_APP_DIR/deploy_backend.sh && cd \$REMOTE_APP_DIR && ./deploy_backend.sh"
          """
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
      cleanWs()
    }
    success { echo '✅ 백엔드 배포 완료' }
    failure { echo '❌ 백엔드 배포 실패' }
  }
}
