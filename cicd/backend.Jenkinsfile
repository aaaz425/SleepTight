pipeline {
  agent any

  environment {
    // Docker 레지스트리 정보
    DOCKER_REGISTRY    = 'xylitol311'
    BACKEND_IMAGE      = 'sleep-tight-backend'

    // 공통 Credentials
    ENV_FILE_ID        = 'env-file-credential'       // .env 파일을 저장한 Secret File 크리덴셜 ID
    DOCKER_HUB_CRED    = 'docker-hub-credentials'    // Docker Hub Username/Password 크리덴셜 ID
    GIT_CRED_ID        = 'gitlab-access-token-credential' // GitLab Personal Access Token 크리덴셜 ID

    // Git 설정
    GIT_BRANCH         = 'dev/be'
    GIT_URL            = 'https://lab.ssafy.com/s12-final/S12P31S303.git'

    // 원격 배포 설정
    DEPLOY_USER        = 'ubuntu'                     // EC2 인스턴스 사용자
    DEPLOY_HOST        = '43.202.63.167'              // EC2 퍼블릭 IP 또는 도메인
    SSH_CREDENTIAL_ID  = 'ec2-ssh-key'                // Jenkins에 등록된 EC2 SSH Key 크리덴셜 ID
    REMOTE_APP_DIR     = '/home/ubuntu/sleep-tight-app' // EC2 배포 디렉토리
    COMPOSE_FILE       = 'cicd/docker-compose.yml'    // 리포지토리 내 docker-compose 경로
  }

  stages {
    stage('Checkout & Prepare') {
      steps {
        // 1) 소스 코드 체크아웃
        git branch: "${GIT_BRANCH}",
            credentialsId: "${GIT_CRED_ID}",
            url: "${GIT_URL}"

        // 2) Jenkins Credential에 저장된 .env 파일을 체크아웃된 워크스페이스로 복사
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

    stage('Build & Push Backend') {
      steps {
        // Docker multi-stage 빌드, 태깅, 푸시
        sh '''
          set -e
          echo "[INFO] Building and pushing backend image"

          cd server/api

          IMAGE_TAG=${DOCKER_REGISTRY}/${BACKEND_IMAGE}:${BUILD_NUMBER}
          LATEST_TAG=${DOCKER_REGISTRY}/${BACKEND_IMAGE}:latest

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

    stage('Deploy Backend') {
      steps {
        sshagent(credentials: [SSH_CREDENTIAL_ID]) {
          sh """
            set -e

            # 1) 원격에 디렉터리 생성
            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} \\
              "mkdir -p ${REMOTE_APP_DIR}"

            # 2) .env 복사
            scp -o StrictHostKeyChecking=no ./.env \\
                ${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_APP_DIR}/.env

            # 3) docker-compose.yml 복사
            scp -o StrictHostKeyChecking=no ${COMPOSE_FILE} \\
                ${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_APP_DIR}/docker-compose.yml

            # 4) 배포 스크립트 복사
            scp -o StrictHostKeyChecking=no cicd/deploy_backend.sh \\
                ${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_APP_DIR}/deploy_backend.sh

            # 5) 원격에서 실행 권한 부여 + 스크립트 실행
            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} \\
              "chmod +x ${REMOTE_APP_DIR}/deploy_backend.sh && \\
              cd ${REMOTE_APP_DIR} && ./deploy_backend.sh"
          """
        }
      }
    }
  }

  post {
    always {
      // 로그아웃 및 워크스페이스 정리
      sh 'docker logout'
      cleanWs()
    }
    success {
      echo '[SUCCESS] 백엔드 배포가 성공적으로 완료되었습니다.'
    }
    failure {
      echo '[FAILURE] 백엔드 배포 중 오류가 발생했습니다.'
    }
  }
}
