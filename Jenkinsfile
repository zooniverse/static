#!groovy

def dockerRepoName = 'zooniverse/http-frontend'
def newImage = null

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
      agent any
      steps {
        script {
          newImage = docker.build("${dockerRepoName}:${GIT_COMMIT}")
          newImage.push()

          if (BRANCH_NAME == 'master') {
            newImage.push('latest')
          }
        }
      }
    }

    stage('Test HTTP response') {
      agent any
      steps {
        script {
          docker.image("${dockerRepoName}:${GIT_COMMIT}").withRun() { nginx_c ->
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

    stage('Update latest tag') {
      when { branch 'master' }
      steps {
        script {
          newImage.push('latest')
        }
      }
    }

    stage('Dry run deployments') {
      agent any
      steps {
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment.tmpl | kubectl --context azure apply --dry-run=client --record -f -"
        sh "kubectl --context azure apply --dry-run=client --record -f kubernetes/ingress/"
      }
    }

    stage('Deploy to Kubernetes') {
      when { branch 'master' }
      agent any
      steps {
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment.tmpl | kubectl --context azure apply --record -f -"
        sh "kubectl --context azure apply --record -f kubernetes/ingress/"
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
