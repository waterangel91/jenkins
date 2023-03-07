pipeline {
    agent { docker { image 'maven:3.9.0-eclipse-temurin-11' } }
    stages {
        stage('build') {
            steps {
                //test
                sh 'mvn --version'
            }
        }
    }
}