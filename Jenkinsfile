pipeline{
    agent any

    environment {
        registryName = 'DanielAcrRegistry'
    }

    stages {
        stage("create docker"){
            steps{
                ws("./webServer"){
                    dockerImage = docker.build registryName
                }
            }
        }
    }
}
