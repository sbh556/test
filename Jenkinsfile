pipeline{
    agent any

    environment {
        registryName = 'DanielAcrRegistry'
    }

    stages {
        stage("delete rogue previes containers and images"){
            steps{
                sh 'docker rm -vf $(docker ps -aq)'
                sh 'docker rmi -f $(docker images -aq)'
            }
        }
        stage("create docker"){
            steps{
                    sh "docker build ./webServer -t 'helloworld:${env.BUILD_ID}'"
                    sh "docker run -p 8000:8000 -d 'helloworld:${env.BUILD_ID}'"
                    sh "curl http://localhost:8000"
            }
        }
    }
}
