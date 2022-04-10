
commit = ''

pipeline {
    agent  none
    options {
        skipDefaultCheckout true
    }
    environment {
        CONTAINER_PREFIX="todem-${env.BUILD_ID}"
        DC="/usr/bin/docker-compose -p ${CONTAINER_PREFIX} -f docker-compose.yml -f docker-compose.jenkins.yml"
        DOCKER_REGISTRY="cdocockpitregistry.azurecr.io"
        CONFIG_ENV="dev"
        IMAGE_PREFIX="${DOCKER_REGISTRY}/dgc-todem"
    }
    stages {
      stage("Prepare") {
        agent { label 'docker' }
        steps {
        checkout scm
        script {
          msg = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
          env.commit = msg
        }
        echo "${env.commit}"
        echo "${env.BRANCH_NAME}"
        }
      }
      stage("Build") {
        agent { label 'docker' }
        steps {
          sh "${DC} build"
        }
      }

      stage("Unit and integration Tests"){
        parallel{

          stage("Unit Test - DEM FRONT") {
            agent { label 'docker' }
            steps {
              sh "docker run --rm ${IMAGE_PREFIX}-front:${env.commit} npm test"
            }
          }
          stage("Unit Test - DEM BACK") {
            agent { label 'docker' }
            steps {
              sh "docker run --rm  -e 'CONFIG_ENV=loc' ${IMAGE_PREFIX}-back:${env.commit} python -m pytest test/"
            }
          }
          stage("Unit Test - TO MGR") {
            agent { label 'docker' }
            steps {
              sh "docker run --rm  -e 'CONFIG_ENV=loc' ${IMAGE_PREFIX}-token-mgr:${env.commit} python -m pytest test/"
            }
          }

        }
      }
      stage("Launch compose") {
        agent { label 'docker' }
        steps {
          sh "${DC} up -d "
        }
      }
      stage("Push images ") {
        when {
          expression { return env.BRANCH_NAME == 'develop' || env.BRANCH_NAME == 'uat' || env.BRANCH_NAME == 'master' }
        }
        agent { label 'docker' }
        steps {
          withCredentials([usernamePassword(credentialsId: 'dgc-docker-registry', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
            sh "docker login  -u $USERNAME -p $PASSWORD ${DOCKER_REGISTRY}"
            sh "${DC} push"
          }
        }
      }
      stage("Deploy in dev") {
        when {
          expression {env.BRANCH_NAME == 'develop'}
        }
        agent { label 'docker' }
        steps {
          script {
                  input message: 'Are you sure you want to deploy in develop ?'
          }
          withCredentials([sshUserPrivateKey(credentialsId: "ssh_deployer_dev", keyFileVariable: 'keyfile'), usernamePassword(credentialsId: 'dgc-docker-registry', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                sh '''
                  ssh -i ${keyfile}  -o StrictHostKeyChecking=no  deployer@ldgcdevweb01cs.cloudapp.net <<-EOF
                  docker login  -u \$USERNAME -p \$PASSWORD \$DOCKER_REGISTRY
                  cd /opt/binaries/dgc-digital-estate-mgr
                  export DOCKER_REGISTRY=\$DOCKER_REGISTRY
                  export CONFIG_ENV=dev
                  export commit=\$commit
                  git checkout develop
                  git pull -r
                  docker-compose -f docker-compose.yml -f docker-compose.deploy.yml pull
                  docker-compose -f docker-compose.yml -f docker-compose.deploy.yml up -d
EOF
                '''
            }
        }
      }

      stage("Deploy in uat") {
        when {
          expression {env.BRANCH_NAME == 'uat'}
        }
        agent { label 'docker' }
        steps {
          script {
                  input message: 'Are you sure you want to deploy in UAT ?'
          }
          withCredentials([sshUserPrivateKey(credentialsId: "ssh_deployer_uat", keyFileVariable: 'keyfile'), usernamePassword(credentialsId: 'dgc-docker-registry', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                sh '''
                  ssh -i ${keyfile}  -o StrictHostKeyChecking=no  deployer@ldgcuatweb01cs.cloudapp.net <<-EOF
                  docker login  -u \$USERNAME -p \$PASSWORD \$DOCKER_REGISTRY
                  cd /opt/binaries/dgc-digital-estate-mgr
                  export DOCKER_REGISTRY=\$DOCKER_REGISTRY
                  export CONFIG_ENV=uat
                  export commit=\$commit
                  git checkout uat
                  git pull -r
                  docker-compose -f docker-compose.yml -f docker-compose.deploy.yml pull
                  docker-compose -f docker-compose.yml -f docker-compose.deploy.yml up -d
EOF
                '''
            }
        }
      }

      stage("Deploy in prod") {
        when {
          expression {env.BRANCH_NAME == 'master'}
        }
        agent { label 'docker' }
        steps {
          script {
                  input message: 'Are you sure you want to deploy in prod ?'
          }
          withCredentials([sshUserPrivateKey(credentialsId: "ssh_deployer_prd", keyFileVariable: 'keyfile'), usernamePassword(credentialsId: 'dgc-docker-registry', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                sh '''
                  ssh -i ${keyfile}  -o StrictHostKeyChecking=no  deployer@ldgcprdweb01cs.cloudapp.net <<-EOF
                  docker login  -u \$USERNAME -p \$PASSWORD \$DOCKER_REGISTRY
                  cd /opt/binaries/dgc-digital-estate-mgr
                  export DOCKER_REGISTRY=\$DOCKER_REGISTRY
                  export CONFIG_ENV=prd
                  export commit=\$commit
                  git checkout master
                  git pull -r
                  docker-compose -f docker-compose.yml -f docker-compose.deploy.yml pull
                  docker-compose -f docker-compose.yml -f docker-compose.deploy.yml up -d
EOF
                '''
            }
        }
      }
   }
    post {
      always {
        script {
          node('docker'){
            currentBuild.result = currentBuild.result ?: 'SUCCESS'
            notifyBitbucket()
            }
        }
      }
      cleanup {
          node('docker'){
          sh "${DC} down -v --rmi local --remove-orphans"
      }}
    }
}

"gunicorn", "-b", "0.0.0.0:5001", "runserver:app",  "-t", "6000"