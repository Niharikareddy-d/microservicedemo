pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        timestamps()
    }

    tools {
        jdk 'jdk17'
        maven 'maven'
    }

    stages {

        stage('Git Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Maven Build & Test') {
            steps {
                sh 'mvn clean test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                        mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                          -Dsonar.projectKey=microservicedemo \
                          -Dsonar.projectName=microservicedemo
                    '''
                }
            }
        }

    }
}
