pipeline {

    agent any

    options {
        skipDefaultCheckout(true)
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(
            logRotator(
                numToKeepStr: '20',
                artifactNumToKeepStr: '10'
            )
        )
    }

    tools {
        jdk 'jdk17'
        maven 'maven'
    }

    environment {
        SONAR_PROJECT_KEY  = 'microservicedemo'
        SONAR_PROJECT_NAME = 'microservicedemo'
    }

    stages {

        stage('Source Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Maven Build & Test') {
            steps {
                sh '''
                    mvn clean test
                '''
            }
        }

        stage('SonarQube Code Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                        mvn \
                          org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                          -Dsonar.projectKey="${SONAR_PROJECT_KEY}" \
                          -Dsonar.projectName="${SONAR_PROJECT_NAME}"
                    '''
                }
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

    }

    post {

        always {
            echo "Pipeline execution completed."
        }

        success {
            echo "CI pipeline completed successfully."
        }

        failure {
            echo "CI pipeline failed. Check the stage logs for details."
        }

    }
}
