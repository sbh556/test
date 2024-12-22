pipeline{
    agent any

    environment {
        registryName = 'DanielAcrRegistry'
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
                int status = sh(script: "curl -sLI -w '%{http_code}' http://localhost:8000 -o /dev/null", returnStdout: true)
                if (status != 200 && status != 201) {
                    error("Returned status code = $status when calling $url")
                }
            }
        }
        stage("delete running containers"){
            sh 'docker rm -vf $(docker ps -aq)'
        }
    }
}
