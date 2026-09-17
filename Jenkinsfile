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

        // Application
        APPLICATION_NAME = 'microservicedemo'

        // SonarQube
        SONAR_PROJECT_KEY  = 'microservicedemo'
        SONAR_PROJECT_NAME = 'microservicedemo'

        // Nexus
        MAVEN_SETTINGS = 'maven-setting'

        // AWS
        AWS_REGION = 'us-east-1'

        // ECR
        ECR_REGISTRY = '058233700821.dkr.ecr.us-east-1.amazonaws.com'

        // EKS
        EKS_CLUSTER_NAME = 'enterprise-test-eks'

        // Kubernetes
        KUBE_CONFIG = '/var/lib/jenkins/.kube/config'
    }

    stages {

        // ============================================================
        // ------ SOURCE CHECKOUT
        // ============================================================

        stage('Source Checkout') {
            steps {
                checkout scm
            }
        }


        // ============================================================
        // ------ MAVEN BUILD & TEST
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
        // ------ SONARQUBE CODE ANALYSIS
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
        // ------ SONARQUBE QUALITY GATE
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
        // ------ NEXUS MAVEN ARTIFACT PUBLISH
        // ============================================================

        stage('Nexus Maven Artifact Publish') {
            steps {

                withMaven(
                    globalMavenSettingsConfig: "${MAVEN_SETTINGS}"
                ) {

                    sh '''
                        set -e

                        mvn deploy -DskipTests
                    '''
                }
            }
        }


        // ============================================================
        // ------ DOCKER IMAGE BUILD
        // ============================================================

        stage('Docker Image Build') {
            steps {

                script {

                    echo "Building Docker images for ${APPLICATION_NAME}"

                    /*
                     * Docker image build implementation
                     * will be added after confirming the
                     * actual microservice Dockerfiles and
                     * image naming convention.
                     */
                }
            }
        }


        // ============================================================
        // ------ TRIVY IMAGE SECURITY SCAN
        // ============================================================

        stage('Trivy Image Security Scan') {
            steps {

                script {

                    echo "Running Trivy security scan"

                    /*
                     * Trivy implementation will scan
                     * each generated application image.
                     */
                }
            }
        }


        // ============================================================
        // ------ NEXUS DOCKER IMAGE PUSH
        // ============================================================

        stage('Nexus Docker Image Push') {
            steps {

                script {

                    echo "Publishing Docker images to Nexus"

                    /*
                     * Nexus Docker repository implementation
                     * will be added using the actual Nexus
                     * Docker repository configuration.
                     */
                }
            }
        }


        // ============================================================
        // ------ AMAZON ECR IMAGE PUSH
        // ============================================================

        stage('Amazon ECR Image Push') {
            steps {

                script {

                    echo "Publishing required Docker images to Amazon ECR"

                    /*
                     * ECR implementation will use the
                     * Jenkins EC2 IAM role for authentication.
                     */
                }
            }
        }


        // ============================================================
        // ------ HELM DEPLOYMENT TO EKS
        // ============================================================

        stage('Helm Deployment to EKS') {
            steps {

                script {

                    echo "Deploying application using Helm"

                    sh '''
                        set -e

                        helm list \
                          --all-namespaces \
                          --kubeconfig "${KUBE_CONFIG}"
                    '''
                }
            }
        }


        // ============================================================
        // ------ DEPLOYMENT VERIFICATION
        // ============================================================

        stage('Deployment Verification') {
            steps {

                sh '''
                    set -e

                    kubectl \
                      --kubeconfig "${KUBE_CONFIG}" \
                      get pods \
                      --all-namespaces
                '''
            }
        }
    }


    // ================================================================
    // ------ PIPELINE POST ACTIONS
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
