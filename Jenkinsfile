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
                        def image = docker.build("helloworld:${env.BUILD_ID}")
                    }
                }
            }
        }
    }
}
