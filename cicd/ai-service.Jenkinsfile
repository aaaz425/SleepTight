pipeline {
  agent any

  environment {
    // Docker 레지스트리 정보
    DOCKER_REGISTRY    = 'xylitol311'
    AI_IMAGE           = 'sleep-tight-ai'

    // 공통 Credentials
    ENV_FILE_ID        = 'env-file-credential'
    DOCKER_HUB_CRED    = 'docker-hub-credentials'
    GIT_CRED_ID        = 'gitlab-access-token-credential'

    // Git 설정
    GIT_BRANCH         = 'dev/be'
    GIT_URL            = 'https://lab.ssafy.com/s12-final/S12P31S303.git'

    // 원격 배포 설정
    DEPLOY_USER        = 'ubuntu'
    DEPLOY_HOST        = '43.202.63.167'
    SSH_CREDENTIAL_ID  = 'ec2-ssh-key'
    REMOTE_APP_DIR     = '/home/ubuntu/sleep-tight-app'
    COMPOSE_FILE       = 'cicd/docker-compose.yml'
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
            echo "[INFO] Copying .env to workspace"
            cp "$ENV_FILE" ./.env
          '''
        }
      }
    }

    stage('Docker Login') {
      steps {
        // Docker Hub에 로그인
        withCredentials([usernamePassword(
          credentialsId: "${DOCKER_HUB_CRED}",
          usernameVariable: 'DOCKERHUB_USR',
          passwordVariable: 'DOCKERHUB_PSW'
        )]) {
          sh '''
            set -e
            echo "[INFO] Docker login"
            echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin
          '''
        }
      }
    }

    stage('Build & Push AI') {
      steps {
        // Docker multi-stage 빌드, 태깅, 푸시
        sh '''
          set -e
          echo "[INFO] Building and pushing AI image"

          cd server/ai

          IMAGE_TAG=${DOCKER_REGISTRY}/${AI_IMAGE}:${BUILD_NUMBER}
          LATEST_TAG=${DOCKER_REGISTRY}/${AI_IMAGE}:latest

          # 1) 이미지 빌드
          docker build -t "$IMAGE_TAG" .

          # 2) latest 태그 추가
          docker tag "$IMAGE_TAG" "$LATEST_TAG"

          # 3) 레지스트리에 푸시
          docker push "$IMAGE_TAG"
          docker push "$LATEST_TAG"
        '''
      }
    }

    stage('Deploy AI') {
      steps {
        sshagent(credentials: ["${SSH_CREDENTIAL_ID}"]) {
          sh """
            set -e
            echo "[INFO] Creating remote directory"
            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} \\
              "mkdir -p ${REMOTE_APP_DIR}"

            echo "[INFO] Copying .env"
            scp -o StrictHostKeyChecking=no ./.env \\
                ${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_APP_DIR}/.env

            echo "[INFO] Copying docker-compose.yml"
            scp -o StrictHostKeyChecking=no ${COMPOSE_FILE} \\
                ${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_APP_DIR}/docker-compose.yml

            echo "[INFO] Copying deploy script"
            scp -o StrictHostKeyChecking=no cicd/deploy_ai.sh \\
                ${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_APP_DIR}/deploy_ai.sh

            echo "[INFO] Setting execute permission and running deploy script"
            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} \\
              "chmod +x ${REMOTE_APP_DIR}/deploy_ai.sh && \\
               cd ${REMOTE_APP_DIR} && ./deploy_ai.sh"
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
      echo '[SUCCESS] AI 서비스 배포가 성공적으로 완료되었습니다.'
    }
    failure {
      echo '[FAILURE] AI 서비스 배포 중 오류가 발생했습니다.'
    }
  }
}
