pipeline {
    agent any

    environment {
        SSH_CRED      = 'ec2-ssh-key'
        DEPLOY_USER   = 'ubuntu'
        DEPLOY_HOST   = '43.202.63.167'
        APP_DIR       = '/home/ubuntu/sleep-tight-app'
        COMPOSE_FILE  = 'docker-compose-infra.yml'
        ENV_FILE_ID   = 'env-file-credential'
    }

    stages {
        stage('Checkout') {
            steps {
                // 전체 레포 + cicd 디렉터리 체크아웃
                checkout([$class: 'GitSCM',
                  branches: [[name: env.GIT_BRANCH ?: 'dev/be']],
                  userRemoteConfigs: [[
                    url: 'https://lab.ssafy.com/s12-final/S12P31S303.git',
                    credentialsId: 'gitlab-access-token-credential'
                  ]]
                ])
                // .env 파일 가져오기
                withCredentials([file(credentialsId: env.ENV_FILE_ID, variable: 'ENV_F')]) {
                  sh 'cp "$ENV_F" ./.env'
                }
            }
        }

        stage('Deploy All Containers') {
            steps {
                sshagent(credentials: [env.SSH_CRED]) {
                  sh """
                    # 1) 원격 디렉터리 및 모니터링 하위 폴더 생성
                    ssh -o StrictHostKeyChecking=no $DEPLOY_USER@$DEPLOY_HOST \\
                      "mkdir -p $APP_DIR/monitoring"

                    # 2) Compose 파일 복사
                    scp -o StrictHostKeyChecking=no \\
                      \${WORKSPACE}/cicd/\${COMPOSE_FILE} \\
                      $DEPLOY_USER@$DEPLOY_HOST:$APP_DIR/\${COMPOSE_FILE}

                    # 3) 모니터링 설정 파일 모두 복사
                    scp -o StrictHostKeyChecking=no \\
                      \${WORKSPACE}/cicd/prometheus.yml \\
                      \${WORKSPACE}/cicd/alarm.rules.yml \\
                      \${WORKSPACE}/cicd/alertmanager.yml \\
                      $DEPLOY_USER@$DEPLOY_HOST:$APP_DIR/monitoring/

                    # 4) .env 복사
                    scp -o StrictHostKeyChecking=no \\
                      ./.env \\
                      $DEPLOY_USER@$DEPLOY_HOST:$APP_DIR/.env

                    # 5) 원격에서 모든 컨테이너 재시작
                    ssh -o StrictHostKeyChecking=no $DEPLOY_USER@$DEPLOY_HOST \\
                      "cd $APP_DIR && \\
                       docker compose -f \${COMPOSE_FILE} down && \\
                       docker compose -f \${COMPOSE_FILE} pull && \\
                       docker compose -f \${COMPOSE_FILE} up -d"
                  """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Infra & Monitoring Stack 배포 완료'
        }
        failure {
            echo '🚨 배포 중 오류 발생!'
        }
    }
}
