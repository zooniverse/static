#!groovy

dockerImageName = 'zooniverse/http-frontend:${BRANCH_NAME}'
newImage = null

pipeline {
  agent none

  options {
    disableConcurrentBuilds()
  }

  stages {
    stage('Notify Slack') {
      when { branch 'master' }
      agent any
      steps {
        slackSend (
          color: '#00FF00',
          message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
          channel: "#ops"
        )
      }
    }

    stage('Build Docker image') {
      steps {
        script {
          newImage = docker.build(dockerImageName)
          newImage.push()
        }
      }
    }

    stage('Test HTTP response') {
      steps {
        script {
          docker.image('zooniverse/image-processing').withRun('-e NODE_ENV=production') { img_proc_c ->
            docker.image(dockerImageName).withRun("--link ${img_proc_c.id}:imgproc") { nginx_c ->
              sleep 30
              sh "docker logs ${nginx_c.id}"
              docker.image('alpine').inside("-u 0 --link ${nginx_c.id}:nginx") {
                sh "apk add --no-cache curl"
                sh "curl -vk https://nginx/index.html"
              }
            }
          }
        }
      }
    }

    stage('Update latest tag') {
      when { branch 'master' }
      steps {
        script {
          newImage.push('latest')
        }
      }
    }

    stage('Build EC2 AMI') {
      when { branch 'master' }
      agent {
        docker {
          image 'zooniverse/operations:latest'
          args '-v "$HOME/.ssh/:/home/ubuntu/.ssh" -v "$HOME/.aws/:/home/ubuntu/.aws"'
        }
      }
      steps {
        script {
          sh 'cd /operations && ./rebuild.sh http-frontend'
        }
      }
    }

    stage('Deploy to AWS') {
      when { branch 'master' }
      agent {
        docker {
          image 'zooniverse/operations:latest'
          args '-v "$HOME/.ssh/:/home/ubuntu/.ssh" -v "$HOME/.aws/:/home/ubuntu/.aws"'
        }
      }
      steps {
        script {
          sh 'cd /operations && ./deploy_latest.sh http-frontend'
        }
      }
    }
  }

  post {
    success {
      script {
        if (BRANCH_NAME == 'master') {
          slackSend (
            color: '#00FF00',
            message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
            channel: "#ops"
          )
        }
      }
    }

    failure {
      script {
        if (BRANCH_NAME == 'master') {
          slackSend (
            color: '#FF0000',
            message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
            channel: "#ops"
          )
        }
      }
    }
  }
}
