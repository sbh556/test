pipeline{
    agent any

    environment {
        registryName = 'DanielAcrRegistry'
        ACRLoginServer = 'danielacrregistry.azurecr.io'
        url = 'http://localhost:8000'
    }

    stages {
        stage("delete rogue images"){
            steps{
                sh  'docker rm -vf $(docker ps -aq) || true' 
                sh 'docker rmi -f $(docker images -aq)'
            }
        }
        stage("create docker"){
            steps{
                sh "docker build ./webServer -t 'helloworld:${env.BUILD_ID}'"
                sh "docker run -p 8000:8000 -d 'helloworld:${env.BUILD_ID}'"
                sh 'sleep 5'
                script{
                    def status = sh(script: "curl -sLI -w '%{http_code}' ${url} -o /dev/null", returnStdout: true).trim()
                    if (status != "200" && status != "201") {
                        error("Returned status code = $status when calling ${url}")
                    }
                }
            }
        }
        stage("push to acr"){
            steps{
                withCredentials([usernamePassword(credentialsId:'ACR',passwordVariable:'acrPassword',usernameVariable:'acrUsername')]){
                    sh "docker login ${ACRLoginServer} -u ${env.acrPassword} -p ${env.acrUsername}"
                }
            }
        }
    }
}
