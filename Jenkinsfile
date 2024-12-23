pipeline{
    agent any

    environment {
        registryName = 'DanielAcrRegistry'
        ACRLoginServer = 'danielacrregistry.azurecr.io'
        dockerName = "helloworld"
        url = 'http://localhost:8000'
    }

    stages {
        stage("delete rogue images"){
            steps{
                sh  'docker rm -vf $(docker ps -aq) || true' 
                sh 'docker rmi -f $(docker images -aq)'
            }
        }
        stage("connect to azure"){
            steps{
                sh 'az login --identity'
            }
        }
        stage("create docker"){
            steps{
                sh "docker build ./webServer -t '${ACRLoginServer}/${dockerName}:latest'"
                sh "docker run -p 8000:8000 -d '${ACRLoginServer}/${dockerName}:latest"
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
                    sh "az acr login -n ${registryName}"
                    sh "docker push ${ACRLoginServer}/${dockerName}:latest"
            }
        }
    }
}
