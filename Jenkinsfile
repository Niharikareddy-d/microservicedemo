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

        /*
         * Application
         */
        APP_NAME = 'microservicedemo'

        /*
         * AWS
         */
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '058233700821'

        /*
         * ECR
         */
        ECR_REGISTRY = '058233700821.dkr.ecr.us-east-1.amazonaws.com'

        /*
         * EKS
         */
        EKS_CLUSTER = 'enterprise-test-eks'
        KUBE_CONFIG = '/var/lib/jenkins/.kube/config'

        /*
         * SonarQube
         */
        SONAR_PROJECT_KEY  = 'microservicedemo'
        SONAR_PROJECT_NAME = 'microservicedemo'

        /*
         * Image version
         *
         * Immutable Jenkins build tag.
         */
        IMAGE_TAG = "${BUILD_NUMBER}"

        /*
         * Helm
         */
        HELM_RELEASE = 'microservices'
        HELM_CHART   = './helm'
    }

    stages {

        // ============================================================
        // STAGE 1 - SOURCE CHECKOUT
        // ============================================================

        stage('Source Checkout') {

            steps {

                checkout scm

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Source Checkout"
                    echo "=========================================="

                    echo "Branch:"
                    git branch --show-current || true

                    echo "Commit:"
                    git rev-parse HEAD

                    echo "Application:"
                    echo "${APP_NAME}"
                '''
            }
        }


        // ============================================================
        // STAGE 2 - MAVEN BUILD & TEST
        // ============================================================

        stage('Maven Build & Test') {

            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Maven Build & Test"
                    echo "=========================================="

                    java -version
                    mvn -version

                    mvn clean test
                '''
            }
        }


        // ============================================================
        // STAGE 3 - SONARQUBE ANALYSIS
        // ============================================================

        stage('SonarQube Code Analysis') {

            steps {

                withSonarQubeEnv('sonar-server') {

                    sh '''
                        set -e

                        echo "=========================================="
                        echo "SonarQube Code Analysis"
                        echo "=========================================="

                        mvn \
                          org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                          -Dsonar.projectKey="${SONAR_PROJECT_KEY}" \
                          -Dsonar.projectName="${SONAR_PROJECT_NAME}"
                    '''
                }
            }
        }


        // ============================================================
        // STAGE 4 - SONARQUBE QUALITY GATE
        // ============================================================

        stage('SonarQube Quality Gate') {

            steps {

                timeout(time: 10, unit: 'MINUTES') {

                    waitForQualityGate abortPipeline: true
                }
            }
        }


        // ============================================================
        // STAGE 5 - DOCKER IMAGE BUILD
        // ============================================================

        stage('Docker Image Build') {

            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Docker Image Build"
                    echo "=========================================="

                    docker version

                    echo ""
                    echo "Building deployment services..."
                    echo ""

                    docker build \
                      -t ${APP_NAME}-gateway:${IMAGE_TAG} \
                      -f gateway-service/Dockerfile .

                    docker build \
                      -t ${APP_NAME}-auth:${IMAGE_TAG} \
                      -f auth-service/Dockerfile .

                    docker build \
                      -t ${APP_NAME}-user:${IMAGE_TAG} \
                      -f user-service/Dockerfile .

                    docker build \
                      -t ${APP_NAME}-admin:${IMAGE_TAG} \
                      -f admin-service/Dockerfile .

                    docker build \
                      -t ${APP_NAME}-employee:${IMAGE_TAG} \
                      -f employee-service/Dockerfile .

                    docker build \
                      -t ${APP_NAME}-customer:${IMAGE_TAG} \
                      -f customer-service/Dockerfile .

                    docker build \
                      -t ${APP_NAME}-hr:${IMAGE_TAG} \
                      -f hr-service/Dockerfile .

                    docker build \
                      -t ${APP_NAME}-task:${IMAGE_TAG} \
                      -f task-service/Dockerfile .

                    echo ""
                    echo "Built images:"
                    docker images | grep "${APP_NAME}"
                '''
            }
        }


        // ============================================================
        // STAGE 6 - TRIVY IMAGE SECURITY SCAN
        // ============================================================

        stage('Trivy Image Security Scan') {

            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Trivy Image Security Scan"
                    echo "=========================================="

                    trivy --version

                    mkdir -p trivy-reports

                    echo ""
                    echo "Scanning gateway..."
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --format table \
                      -o trivy-reports/gateway-${IMAGE_TAG}.txt \
                      ${APP_NAME}-gateway:${IMAGE_TAG}

                    echo ""
                    echo "Scanning auth..."
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --format table \
                      -o trivy-reports/auth-${IMAGE_TAG}.txt \
                      ${APP_NAME}-auth:${IMAGE_TAG}

                    echo ""
                    echo "Scanning user..."
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --format table \
                      -o trivy-reports/user-${IMAGE_TAG}.txt \
                      ${APP_NAME}-user:${IMAGE_TAG}

                    echo ""
                    echo "Scanning admin..."
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --format table \
                      -o trivy-reports/admin-${IMAGE_TAG}.txt \
                      ${APP_NAME}-admin:${IMAGE_TAG}

                    echo ""
                    echo "Scanning employee..."
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --format table \
                      -o trivy-reports/employee-${IMAGE_TAG}.txt \
                      ${APP_NAME}-employee:${IMAGE_TAG}

                    echo ""
                    echo "Scanning customer..."
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --format table \
                      -o trivy-reports/customer-${IMAGE_TAG}.txt \
                      ${APP_NAME}-customer:${IMAGE_TAG}

                    echo ""
                    echo "Scanning hr..."
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --format table \
                      -o trivy-reports/hr-${IMAGE_TAG}.txt \
                      ${APP_NAME}-hr:${IMAGE_TAG}

                    echo ""
                    echo "Scanning task..."
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --format table \
                      -o trivy-reports/task-${IMAGE_TAG}.txt \
                      ${APP_NAME}-task:${IMAGE_TAG}

                    echo ""
                    echo "Trivy scan completed successfully."
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


        // ============================================================
        // STAGE 7 - AMAZON ECR LOGIN
        // ============================================================

        stage('Amazon ECR Authentication') {

            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Amazon ECR Authentication"
                    echo "=========================================="

                    aws sts get-caller-identity

                    aws ecr get-login-password \
                      --region ${AWS_REGION} \
                    | docker login \
                      --username AWS \
                      --password-stdin \
                      ${ECR_REGISTRY}

                    echo "ECR authentication successful."
                '''
            }
        }


        // ============================================================
        // STAGE 8 - AMAZON ECR IMAGE TAG & PUSH
        // ============================================================

        stage('Amazon ECR Image Push') {

            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Amazon ECR Image Push"
                    echo "=========================================="

                    echo "Tagging images..."

                    docker tag \
                      ${APP_NAME}-gateway:${IMAGE_TAG} \
                      ${ECR_REGISTRY}/terraform-platform-test-gateway-service:${IMAGE_TAG}

                    docker tag \
                      ${APP_NAME}-auth:${IMAGE_TAG} \
                      ${ECR_REGISTRY}/terraform-platform-test-auth-service:${IMAGE_TAG}

                    docker tag \
                      ${APP_NAME}-user:${IMAGE_TAG} \
                      ${ECR_REGISTRY}/terraform-platform-test-user-service:${IMAGE_TAG}

                    docker tag \
                      ${APP_NAME}-admin:${IMAGE_TAG} \
                      ${ECR_REGISTRY}/terraform-platform-test-admin-service:${IMAGE_TAG}

                    docker tag \
                      ${APP_NAME}-employee:${IMAGE_TAG} \
                      ${ECR_REGISTRY}/terraform-platform-test-employee-service:${IMAGE_TAG}

                    docker tag \
                      ${APP_NAME}-customer:${IMAGE_TAG} \
                      ${ECR_REGISTRY}/terraform-platform-test-customer-service:${IMAGE_TAG}

                    docker tag \
                      ${APP_NAME}-hr:${IMAGE_TAG} \
                      ${ECR_REGISTRY}/terraform-platform-test-hr-service:${IMAGE_TAG}

                    docker tag \
                      ${APP_NAME}-task:${IMAGE_TAG} \
                      ${ECR_REGISTRY}/terraform-platform-test-task-service:${IMAGE_TAG}


                    echo ""
                    echo "Pushing gateway..."
                    docker push \
                      ${ECR_REGISTRY}/terraform-platform-test-gateway-service:${IMAGE_TAG}

                    echo ""
                    echo "Pushing auth..."
                    docker push \
                      ${ECR_REGISTRY}/terraform-platform-test-auth-service:${IMAGE_TAG}

                    echo ""
                    echo "Pushing user..."
                    docker push \
                      ${ECR_REGISTRY}/terraform-platform-test-user-service:${IMAGE_TAG}

                    echo ""
                    echo "Pushing admin..."
                    docker push \
                      ${ECR_REGISTRY}/terraform-platform-test-admin-service:${IMAGE_TAG}

                    echo ""
                    echo "Pushing employee..."
                    docker push \
                      ${ECR_REGISTRY}/terraform-platform-test-employee-service:${IMAGE_TAG}

                    echo ""
                    echo "Pushing customer..."
                    docker push \
                      ${ECR_REGISTRY}/terraform-platform-test-customer-service:${IMAGE_TAG}

                    echo ""
                    echo "Pushing hr..."
                    docker push \
                      ${ECR_REGISTRY}/terraform-platform-test-hr-service:${IMAGE_TAG}

                    echo ""
                    echo "Pushing task..."
                    docker push \
                      ${ECR_REGISTRY}/terraform-platform-test-task-service:${IMAGE_TAG}

                    echo ""
                    echo "All ECR images pushed successfully."
                '''
            }
        }


        // ============================================================
        // STAGE 9 - HELM VALIDATION
        // ============================================================

        stage('Helm Validation') {

            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Helm Validation"
                    echo "=========================================="

                    test -f helm/Chart.yaml
                    test -f helm/values.yaml

                    helm version

                    cd helm

                    helm lint .

                    helm template ${HELM_RELEASE} .
                '''
            }
        }


        // ============================================================
        // STAGE 10 - HELM DEPLOYMENT TO EKS
        // ============================================================

        stage('Helm Deployment to EKS') {

            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "Helm Deployment to EKS"
                    echo "=========================================="

                    echo "Verifying EKS access..."

                    aws eks describe-cluster \
                      --name ${EKS_CLUSTER} \
                      --region ${AWS_REGION} \
                      --query 'cluster.status' \
                      --output text

                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      get nodes


                    echo ""
                    echo "Deploying application..."

                    helm upgrade --install \
                      ${HELM_RELEASE} \
                      ${HELM_CHART} \
                      --kubeconfig ${KUBE_CONFIG} \
                      --wait \
                      --timeout 10m \
                      --atomic

                    echo ""
                    echo "Helm release status:"

                    helm status \
                      ${HELM_RELEASE} \
                      --kubeconfig ${KUBE_CONFIG}
                '''
            }
        }


        // ============================================================
        // STAGE 11 - DEPLOYMENT VERIFICATION
        // ============================================================

        stage('Deployment Verification') {

            steps {

                sh '''
                    set -e

                    echo "=========================================="
                    echo "EKS Deployment Verification"
                    echo "=========================================="

                    echo ""
                    echo "Namespaces:"
                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      get namespaces


                    echo ""
                    echo "Pods:"
                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      get pods \
                      --all-namespaces


                    echo ""
                    echo "Services:"
                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      get services \
                      --all-namespaces


                    echo ""
                    echo "Deployments:"
                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      get deployments \
                      --all-namespaces


                    echo ""
                    echo "Ingress:"
                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      get ingress \
                      --all-namespaces


                    echo ""
                    echo "Helm releases:"
                    helm list \
                      --all-namespaces \
                      --kubeconfig ${KUBE_CONFIG}


                    echo ""
                    echo "Checking deployment readiness..."

                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      rollout status deployment/gateway-service \
                      -n gateway \
                      --timeout=5m

                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      rollout status deployment/auth-service \
                      -n auth \
                      --timeout=5m

                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      rollout status deployment/user-service \
                      -n user \
                      --timeout=5m

                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      rollout status deployment/admin-service \
                      -n admin \
                      --timeout=5m

                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      rollout status deployment/employee-service \
                      -n employee \
                      --timeout=5m

                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      rollout status deployment/customer-service \
                      -n customer \
                      --timeout=5m

                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      rollout status deployment/hr-service \
                      -n hr \
                      --timeout=5m

                    kubectl \
                      --kubeconfig ${KUBE_CONFIG} \
                      rollout status deployment/task-service \
                      -n task \
                      --timeout=5m

                    echo ""
                    echo "=========================================="
                    echo "EKS DEPLOYMENT VERIFIED"
                    echo "=========================================="
                '''
            }
        }
    }


    // ================================================================
    // POST ACTIONS
    // ================================================================

    post {

        always {

            echo "=========================================="
            echo "Pipeline execution completed."
            echo "Build: ${BUILD_NUMBER}"
            echo "Image Tag: ${IMAGE_TAG}"
            echo "=========================================="
        }

        success {

            echo "Enterprise CI/CD pipeline completed successfully."
        }

        failure {

            echo "Enterprise CI/CD pipeline failed."
            echo "Review the failed stage and console output."
        }

        cleanup {

            sh '''
                docker image prune -f || true
            '''
        }
    }
}
