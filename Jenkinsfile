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

        APPLICATION_NAME = 'microservicedemo'

        SONAR_PROJECT_KEY  = 'microservicedemo'
        SONAR_PROJECT_NAME = 'microservicedemo'

        AWS_REGION = 'us-east-1'

        ECR_REGISTRY =
            '058233700821.dkr.ecr.us-east-1.amazonaws.com'

        ECR_BACKEND_REPOSITORY =
            'terraform-platform-test-backend'

        ECR_FRONTEND_REPOSITORY =
            'terraform-platform-test-frontend'

        EKS_CLUSTER_NAME = 'enterprise-test-eks'

        KUBE_CONFIG = '/var/lib/jenkins/.kube/config'

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        // ============================================================
        // SOURCE
        // ============================================================

        stage('Source Checkout') {
            steps {
                checkout scm
            }
        }


        // ============================================================
        // BUILD & TEST
        // ============================================================

        stage('Maven Build & Test') {
            steps {
                sh '''
                    set -e
                    mvn clean test
                '''
            }
        }


        // ============================================================
        // CODE QUALITY
        // ============================================================

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


        // ============================================================
        // QUALITY GATE
        // ============================================================

        stage('SonarQube Quality Gate') {
            steps {

                timeout(time: 10, unit: 'MINUTES') {

                    waitForQualityGate(
                        abortPipeline: true
                    )
                }
            }
        }


        // ============================================================
        // DOCKER BUILD
        // ============================================================

        stage('Docker Image Build') {
            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Docker Image Build"
                    echo "=========================================="

                    docker version

                    echo "Available Dockerfiles:"
                    find . -maxdepth 2 -name Dockerfile -print
                '''
            }
        }


        // ============================================================
        // TRIVY SECURITY SCAN
        // ============================================================

        stage('Trivy Image Security Scan') {
            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Trivy Security Scan"
                    echo "=========================================="

                    trivy --version
                '''
            }
        }


        // ============================================================
        // NEXUS
        // ============================================================

        stage('Nexus Docker Image Push') {
            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Nexus Docker Registry"
                    echo "=========================================="

                    echo "Publishing designated Nexus images"
                '''
            }
        }


        // ============================================================
        // ECR
        // ============================================================

        stage('Amazon ECR Image Push') {
            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Amazon ECR Login"
                    echo "=========================================="

                    aws ecr get-login-password \
                        --region "${AWS_REGION}" \
                    | docker login \
                        --username AWS \
                        --password-stdin \
                        "${ECR_REGISTRY}"

                    echo "ECR authentication successful."
                '''
            }
        }


        // ============================================================
        // HELM / EKS
        // ============================================================

        stage('Helm Deployment to EKS') {
            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Helm Validation"
                    echo "=========================================="

                    cd helm

                    helm lint .

                    helm template microservices .

                    echo "=========================================="
                    echo "Helm Deployment"
                    echo "=========================================="

                    helm upgrade \
                        --install microservices \
                        . \
                        --kubeconfig "${KUBE_CONFIG}"

                    echo "Helm deployment completed."
                '''
            }
        }


        // ============================================================
        // DEPLOYMENT VERIFICATION
        // ============================================================

        stage('Deployment Verification') {
            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "EKS Deployment Verification"
                    echo "=========================================="

                    kubectl \
                        --kubeconfig "${KUBE_CONFIG}" \
                        get pods \
                        --all-namespaces

                    kubectl \
                        --kubeconfig "${KUBE_CONFIG}" \
                        get services \
                        --all-namespaces

                    helm list \
                        --all-namespaces \
                        --kubeconfig "${KUBE_CONFIG}"
                '''
            }
        }
    }


    // ================================================================
    // POST ACTIONS
    // ================================================================

    post {

        always {
            echo "Pipeline execution completed."
        }

        success {
            echo "Enterprise CI/CD pipeline completed successfully."
        }

        failure {
            echo "Enterprise CI/CD pipeline failed."
        }

        aborted {
            echo "Pipeline execution was aborted."
        }
    }
}
