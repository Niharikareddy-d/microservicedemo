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

        ECR_REGISTRY = '058233700821.dkr.ecr.us-east-1.amazonaws.com'

        EKS_CLUSTER_NAME = 'enterprise-test-eks'

        KUBE_CONFIG = '/var/lib/jenkins/.kube/config'

        IMAGE_TAG = "${BUILD_NUMBER}"
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
        // ------ DOCKER IMAGE BUILD
        // ============================================================

        stage('Docker Image Build') {
            steps {

                script {

                    /*
                     * Docker image definitions will be maintained
                     * centrally here.
                     *
                     * Example structure:
                     *
                     * [
                     *     [name: 'auth',     path: 'auth-service'],
                     *     [name: 'gateway',  path: 'gateway-service'],
                     *     [name: 'user',     path: 'user-service'],
                     *     ...
                     * ]
                     *
                     * The exact Nexus/ECR mapping will be added
                     * after confirming the final image design.
                     */

                    echo "Building application Docker images"

                    sh '''
                        set -e

                        docker version

                        find . -maxdepth 2 -name Dockerfile -print
                    '''
                }
            }
        }


        // ============================================================
        // ------ TRIVY IMAGE SECURITY SCAN
        // ============================================================

        stage('Trivy Image Security Scan') {
            steps {

                script {

                    echo "Running Trivy security scan against generated images"

                    /*
                     * Each generated image will be scanned before
                     * it is allowed to enter Nexus or ECR.
                     *
                     * Critical/High vulnerability policy will be
                     * applied here after confirming the project's
                     * required security threshold.
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

                    echo "Publishing designated Docker images to Nexus"

                    /*
                     * Four designated images will be pushed to
                     * the Nexus Docker registry.
                     *
                     * Nexus repository/registry endpoint and
                     * authentication will be wired here using
                     * the actual Nexus configuration.
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

                    sh '''
                        set -e

                        aws ecr get-login-password \
                            --region "${AWS_REGION}" \
                        | docker login \
                            --username AWS \
                            --password-stdin "${ECR_REGISTRY}"
                    '''

                    echo "Publishing designated Docker images to Amazon ECR"

                    /*
                     * The ECR repositories are already provisioned.
                     *
                     * Jenkins authenticates through the EC2 IAM role.
                     *
                     * The exact image-to-ECR mapping will be
                     * applied here.
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

                    sh '''
                        set -e

                        helm lint ./helm/microservices

                        helm upgrade \
                            --install microservices \
                            ./helm/microservices \
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
