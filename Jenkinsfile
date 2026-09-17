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

        timeout(time: 60, unit: 'MINUTES')
    }

    tools {
        jdk 'jdk17'
        maven 'maven'
    }

    environment {

        AWS_REGION = 'us-east-1'
        EKS_CLUSTER = 'enterprise-test-eks'

        ECR_REGISTRY = '058233700821.dkr.ecr.us-east-1.amazonaws.com'

        SONAR_PROJECT_KEY  = 'microservicedemo'
        SONAR_PROJECT_NAME = 'microservicedemo'

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Source Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Pipeline Configuration Validation') {
            steps {
                sh '''
                    set -e

                    echo "Validating CI/CD configuration..."

                    command -v git
                    command -v mvn
                    command -v docker
                    command -v trivy
                    command -v aws
                    command -v kubectl
                    command -v helm

                    test -f pom.xml
                    test -f helm/Chart.yaml
                    test -f helm/values.yaml

                    aws sts get-caller-identity

                    aws eks describe-cluster \
                      --name "${EKS_CLUSTER}" \
                      --region "${AWS_REGION}" \
                      >/dev/null

                    echo "CI/CD configuration validation successful."
                '''
            }
        }

        stage('Maven Build & Test') {
            steps {
                sh '''
                    set -e
                    mvn clean test
                '''
            }
        }

        stage('SonarQube Code Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                        set -e

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

        stage('Docker Image Build') {
            steps {
                sh '''
                    set -e

                    services="
                        gateway
                        auth
                        user
                        admin
                        employee
                        customer
                        hr
                        task
                    "

                    for service in $services
                    do
                        docker build \
                          -t "microservicedemo-${service}:${IMAGE_TAG}" \
                          -f "${service}-service/Dockerfile" .
                    done

                    docker images | grep microservicedemo
                '''
            }
        }

        stage('Trivy Image Security Scan') {
            steps {
                sh '''
                    set -e

                    rm -rf trivy-reports
                    mkdir -p trivy-reports

                    services="
                        gateway
                        auth
                        user
                        admin
                        employee
                        customer
                        hr
                        task
                    "

                    for service in $services
                    do
                        trivy image \
                          --severity HIGH,CRITICAL \
                          --format table \
                          -o "trivy-reports/${service}-${IMAGE_TAG}.txt" \
                          "microservicedemo-${service}:${IMAGE_TAG}"
                    done
                '''
            }

            post {
                always {
                    archiveArtifacts(
                        artifacts: 'trivy-reports/*.txt',
                        allowEmptyArchive: true
                    )
                }
            }
        }

        stage('Nexus Docker Image Push') {
            steps {
                sh '''
                    set -e

                    echo "Nexus Docker image publishing..."
                    echo "Nexus registry must be configured here."

                    # Nexus image mapping goes here.
                '''
            }
        }

        stage('Amazon ECR Authentication') {
            steps {
                sh '''
                    set -e

                    aws ecr get-login-password \
                      --region "${AWS_REGION}" \
                    | docker login \
                      --username AWS \
                      --password-stdin "${ECR_REGISTRY}"
                '''
            }
        }

        stage('Amazon ECR Image Push') {
            steps {
                sh '''
                    set -e

                    # ECR image mapping goes here.
                '''
            }
        }

        stage('Helm Validation') {
            steps {
                sh '''
                    set -e

                    helm lint helm
                    helm template microservices helm
                '''
            }
        }

        stage('Helm Deployment to EKS') {
            steps {
                sh '''
                    set -e

                    aws eks update-kubeconfig \
                      --name "${EKS_CLUSTER}" \
                      --region "${AWS_REGION}" \
                      --kubeconfig "${WORKSPACE}/kubeconfig"

                    helm upgrade --install microservices helm \
                      --kubeconfig "${WORKSPACE}/kubeconfig" \
                      --namespace microservices \
                      --create-namespace \
                      --wait \
                      --timeout 10m
                '''
            }
        }

        stage('Deployment Verification') {
            steps {
                sh '''
                    set -e

                    kubectl \
                      --kubeconfig "${WORKSPACE}/kubeconfig" \
                      get pods -A

                    kubectl \
                      --kubeconfig "${WORKSPACE}/kubeconfig" \
                      get deployments -A

                    kubectl \
                      --kubeconfig "${WORKSPACE}/kubeconfig" \
                      get services -A
                '''
            }
        }
    }

    post {

        always {
            echo "Pipeline execution completed."
        }

        success {
            echo "ENTERPRISE CI/CD PIPELINE SUCCESS"
        }

        failure {
            echo "ENTERPRISE CI/CD PIPELINE FAILED"
        }
    }
}
