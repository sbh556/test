pipeline{
    agent any

    environment {
        registryName = 'DanielAcrRegistry'
    }

    stages {
        stage("create docker"){
            steps{
                ws("./webServer"){
                    script{
                        sh "docker build . -t 'helloworld:${env.BUILD_ID}'"
                    }
                }
            }
        }
    }
}
