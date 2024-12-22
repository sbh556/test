pipeline{
    agent any

    environment {
        registryName = 'DanielAcrRegistry'
    }

    stages {
        stage("create docker"){
            steps{
                    sh 'ls'
                    sh "docker build ./webServer -t 'helloworld:${env.BUILD_ID}'"
            }
        }
    }
}
