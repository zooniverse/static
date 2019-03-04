#!groovy

node {
    checkout scm

    def dockerImageName = 'zooniverse/http-frontend:${BRANCH_NAME}'
    def newImage = null

    stage('Build Docker image') {
        newImage = docker.build(dockerImageName)
        newImage.push()
    }

    stage('Test HTTP response') {
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

    if (BRANCH_NAME == 'master') {
        stage('Update latest tag') {
            newImage.push('latest')
        }

        stage('Build EC2 AMI') {
            sh 'cd "/var/jenkins_home/jobs/Zooniverse GitHub/jobs/operations/branches/master/workspace" && ./rebuild.sh http-frontend'
        }

        stage('Deploy to AWS') {
            sh 'cd "/var/jenkins_home/jobs/Zooniverse GitHub/jobs/operations/branches/master/workspace" && ./deploy_latest.sh http-frontend'
        }
    }
}
