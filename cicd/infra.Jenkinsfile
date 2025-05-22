pipeline {
    agent any

    environment {
        // EC2 SSH credential (SSH Username with private key, ID: ec2-ssh-key)
        SSH_CRED = 'ec2-ssh-key'
        DEPLOY_USER = 'ubuntu'
        DEPLOY_HOST = '43.202.63.167'
        APP_DIR = '/home/ubuntu/sleep-tight-app'
        COMPOSE_FILE = 'docker-compose-infra.yml'
        ENV_FILE_ID = 'env-file-credential'  // .env 를 관리하는 Jenkins 크리덴셜
    }

    stages {
        stage('Checkout Compose') {
          steps {
            // 코드 리포지토리에서 docker-compose-infra.yml과 .env 가져오기
            checkout([$class: 'GitSCM',
              branches: [[name: env.GIT_BRANCH ?: 'dev/be']],
              userRemoteConfigs: [[
                url: 'https://lab.ssafy.com/s12-final/S12P31S303.git',
                credentialsId: 'gitlab-access-token-credential'
              ]]
            ])
            // .env 파일은 Secret file credential 로 관리했다면, 여기서 복사
            withCredentials([file(credentialsId: env.ENV_FILE_ID, variable: 'ENV_F')]) {
              sh '''
                cp "$ENV_F" ./.env
              '''
            }
          }
        }

        stage('Deploy Infra') {
      steps {
        sshagent(credentials: [env.SSH_CRED]) {
          sh """
                      # 1) 디렉터리 생성 및 파일 복사 (기존과 동일)
                      ssh -o StrictHostKeyChecking=no $DEPLOY_USER@$DEPLOY_HOST \\
                        "mkdir -p $APP_DIR"

                      scp -o StrictHostKeyChecking=no \\
                        ${WORKSPACE}/cicd/${COMPOSE_FILE} \\
                        $DEPLOY_USER@$DEPLOY_HOST:$APP_DIR/${COMPOSE_FILE}

                      scp -o StrictHostKeyChecking=no ./.env \\
                        $DEPLOY_USER@$DEPLOY_HOST:$APP_DIR/.env

                      # 2) 원격에서 docker-compose down → pull → up
                      ssh -o StrictHostKeyChecking=no $DEPLOY_USER@$DEPLOY_HOST \\
                        "cd $APP_DIR && \\
                         docker compose -f ${COMPOSE_FILE} down && \\
                         docker compose -f ${COMPOSE_FILE} pull && \\
                         docker compose -f ${COMPOSE_FILE} up -d"
                    """
        }
      }
        }
    }

    post {
        success {
      echo '인프라(데이터베이스·캐시·MQ) 배포 완료'
        }
        failure {
      echo '인프라 배포 중 오류 발생'
        }
    }
}
