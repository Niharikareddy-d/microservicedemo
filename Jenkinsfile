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

    environment {
        AWS_REGION       = 'us-east-1'
        AWS_ACCOUNT_ID   = '058233700821'
        EKS_CLUSTER_NAME = 'enterprise-test-eks'

        SONAR_PROJECT_KEY  = 'microservicedemo'
        SONAR_PROJECT_NAME = 'microservicedemo'
    }

    stages {

        stage('Source Checkout') {
            steps {
                checkout scm
            }
        }

        stage('CI - Change Detection') {
            steps {
                sh './ci/change-detection.sh'
            }
        }

        stage('CI - Maven Build') {
            steps {
                sh './ci/build.sh'
            }
        }

        stage('CI - Unit Test') {
            steps {
                sh './ci/unittest.sh'
            }
        }

        stage('CI - SonarQube') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh './ci/sonar.sh'
                }
            }
        }

        stage('CI - Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('CI - Docker Build') {
            steps {
                sh './ci/docker-build.sh'
            }
        }

        stage('CI - Trivy Scan') {
            steps {
                sh './ci/trivy.sh'
            }
        }

        stage('CD - Nexus') {
            steps {
                sh './cd/nexus.sh'
            }
        }

        stage('CD - ECR') {
            steps {
                sh './cd/ecr.sh'
            }
        }

        stage('CD - Helm Deployment') {
            steps {
                sh './cd/helm.sh'
            }
        }

        stage('CD - Smoke Test') {
            steps {
                sh './cd/smoke-test.sh'
            }
        }

        stage('CD - Deployment Verification') {
            steps {
                sh './cd/verify.sh'
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
        }

        success {
            echo 'CI/CD pipeline completed successfully.'
        }

        failure {
            echo 'CI/CD pipeline failed. Check the failed stage logs.'
        }
    }
}
