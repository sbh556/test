pipeline{
    agent any

    environment {
        registryName = 'DanielAcrRegistry'
        url = 'http://localhost:8000'
    }

    stages {
        stage("delete rogue images"){
            steps{
                sh 'docker rmi -f $(docker images -aq)'
            }
        }
        stage("create docker"){
            steps{
                sh "docker build ./webServer -t 'helloworld:${env.BUILD_ID}'"
                sh "docker run -p 8000:8000 -d 'helloworld:${env.BUILD_ID}'"
                script{
                    int status = sh(script: "curl -sLI -w '%{http_code}' ${url} -o /dev/null", returnStdout: true)
                    if (status != 200 && status != 201) {
                        error("Returned status code = $status when calling ${url}")
                    }
                }
            }
        }
        stage("delete running containers"){
            steps{
                sh 'docker rm -vf $(docker ps -aq)'
            }
        }
    }
}
